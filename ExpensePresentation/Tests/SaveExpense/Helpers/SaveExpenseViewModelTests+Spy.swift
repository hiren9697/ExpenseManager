//
//  File.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import ExpenseFeature

extension SaveExpenseViewModelTests {
    @MainActor
    class Spy: Sendable {
        enum Message { 
            case saveExpenses(draft: DraftExpense) 
        }
        
        var messages: [Message] = []
        
        private var requests: [(stream: AsyncThrowingStream<Void, Error>,
                                continuation: AsyncThrowingStream<Void, Error>.Continuation)] = []
        
        func save(draft: DraftExpense) async throws {
            messages.append(.saveExpenses(draft: draft))
            
            throw CancellationError()
        }
        
        func completeSaveSuccessfully(at index: Int = 0) {
            requests[index].continuation.yield()
            requests[index].continuation.finish()
        }
        
        func completeSaveWithError(_ error: Error, at index: Int = 0) {
            requests[index].continuation.finish(throwing: error)
        }
    } 
}
