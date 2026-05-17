//
//  SaveExpenseViewModelTests+Spy.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Foundation
import ExpenseFeature
@testable import ExpensePresentation

extension SaveExpenseViewModelTests {
    @MainActor
    class Spy: Sendable {
        enum Message: Equatable { 
            case save(DraftExpense) 
        }
        
        var messages: [Message] = []
        
        private var requests: [(stream: AsyncThrowingStream<Void, Error>,
                                continuation: AsyncThrowingStream<Void, Error>.Continuation)] = []
        
        func save(draft: DraftExpense) async throws {
            messages.append(.save(draft))
            
            let (stream, continuation) = AsyncThrowingStream<Void, Error>.makeStream()
            requests.append((stream, continuation))
            
            for try await _ in stream {
                return
            }
            
            throw CancellationError()
        }
        
        func completeSaveSuccessfully(at index: Int = 0) {
            requests[index].continuation.yield(())
            requests[index].continuation.finish()
        }
        
        func completeSaveWithError(_ error: Error, at index: Int = 0) {
            requests[index].continuation.finish(throwing: error)
        }
    } 
}
