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
    /*
    @Test 
    func test_fetch_requests_expenses() async throws {
        // Arrange
        try await makeSUT(action: { sut, spy in
         // Act
            let _ = await sut.fetch()
        
        // Assert   
            
        })
    }
     */
    
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
        private var loadCompleters: [CheckedContinuation<[Expense], Error>] = []
        
        func loadExpenses() async throws -> [Expense] {
            messages.append(.loadExpenses)
            
            return try await withCheckedThrowingContinuation { continuation in
                loadCompleters.append(continuation)
            }
        }
        
        func completeExpensesLoading(with expenses: [Expense] = [], at index: Int = 0) {
            loadCompleters[index].resume(returning: expenses)
        }
        
        func completeExpensesLoadingWithError(_ error: Error, at index: Int = 0) {
            loadCompleters[index].resume(throwing: error)
        }
    }
}
