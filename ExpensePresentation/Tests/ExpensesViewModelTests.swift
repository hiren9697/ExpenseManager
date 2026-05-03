//
//  File.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 02/05/26.
//

import Foundation
import ExpenseFeature
import ExpensePresentation
import Testing

@Suite(.timeLimit(.minutes(1)))
@MainActor
final class ExpensesViewModelTests {
    // MARK: - Tests
    @Test 
    func fetch_requests_expenses() async throws {
        // Arrange
        try await makeSUT(action: { sut, spy in
            // Act
            let firstFetchTask = Task {
                await sut.fetch()
            }
            await Task.yield() 
            spy.completeExpensesLoading(with: [], at: 0)
            let _ = await firstFetchTask.value
            
            // Assert   
            #expect(spy.messages == [.loadExpenses])

            // Act
            let secondFetchTask = Task { await sut.fetch() }
            await Task.yield()
            spy.completeExpensesLoading(with: [], at: 1)
            let _ = await secondFetchTask.value
            
            // Assert   
            #expect(spy.messages == [.loadExpenses, .loadExpenses])
        })
    }

    @Test
    func isLoadingstate_isEnabled_whileFetching() async throws {
        // Arrange
        try await makeSUT(action: { sut, spy in
            // Act
            let firstFetchTask = Task {
                await sut.fetch()
            }
            await Task.yield() 
            
            // Assert
            #expect(sut.isLoading)
            
            // Act
            spy.completeExpensesLoading(with: [], at: 0)
            _ = await firstFetchTask.value
            
            // Assert
            #expect(sut.isLoading == false)

            // Act
            let secondFetchTask = Task {
                await sut.fetch()
            }
            await Task.yield() 
            
            // Assert
            #expect(sut.isLoading)
            
            // Act
            spy.completeExpensesLoading(with: [], at: 1)
            _ = await secondFetchTask.value
            
            // Assert
            #expect(sut.isLoading == false)
        })
    }
    
    @MainActor
    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation,
                         action: (ExpensesViewModel, Spy) async throws -> Void) async throws {
        try await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let spy = Spy()
            let sut = ExpensesViewModel(loadExpenses: spy.loadExpenses)   
            await tracker(spy, sut)
            
            try await action(sut, spy)
        })
    }
    
    // MARK: - Helpers
    @MainActor
    class Spy: Sendable {
        enum Message { 
            case loadExpenses 
        }
        
        var messages: [Message] = []
        
        private var requests: [(stream: AsyncThrowingStream<[Expense], Error>,
                                continuation: AsyncThrowingStream<[Expense], Error>.Continuation)] = []
        
        func loadExpenses() async throws -> [Expense] {
            messages.append(.loadExpenses)
            
            let (stream, continuation) = AsyncThrowingStream<[Expense], Error>.makeStream()
            requests.append((stream, continuation))
            
            for try await result in stream {
                return result
            }
            
            throw CancellationError()
        }
        
        func completeExpensesLoading(with expenses: [Expense] = [], at index: Int = 0) {
            requests[index].continuation.yield(expenses)
            requests[index].continuation.finish()
        }
        
        func completeExpensesLoadingWithError(_ error: Error, at index: Int = 0) {
            requests[index].continuation.finish(throwing: error)
        }
    }
}
