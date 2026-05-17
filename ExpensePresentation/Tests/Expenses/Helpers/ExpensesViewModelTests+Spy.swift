//
//  File.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import ExpenseFeature

extension ExpensesViewModelTests {
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
