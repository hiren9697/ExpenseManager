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
        private enum AsyncResult {
            case success
            case failure
            case cancelled
        }
        enum Message: Equatable { 
            case save(DraftExpense) 
        }
        private struct Request {
            let param: Message
            let stream: AsyncThrowingStream<Void, Error>
            let continuation: AsyncThrowingStream<Void, Error>.Continuation
            var result: AsyncResult?
        }
        private struct NoResponse: Error {}
        private struct Timeout: Error {}
        
        private var requests: [Request] = []
        
        var messages: [Message] { requests.map(\.param) }
        
        func save(draft: DraftExpense) async throws {
            let index = requests.count
            let (stream, continuation) = AsyncThrowingStream<Void, Error>.makeStream()
            requests.append(Request(param: .save(draft), stream: stream, continuation: continuation))
            
            do {
                for try await _ in stream {
                    try Task.checkCancellation()
                    requests[index].result = .success
                    return
                }
                
                try Task.checkCancellation()
                
                throw NoResponse()
            } catch {
                requests[index].result = Task.isCancelled ? .cancelled : .failure
                throw error
            }
        }
        
        func completeSaveSuccessfullyAndWaitUntilConsumed(at index: Int = 0) async {
            requests[index].continuation.yield(())
            requests[index].continuation.finish()
            while requests[index].result == nil { await Task.yield() }
        }
        
        func completeSaveWithErrorAndWaitUntilConsumed(_ error: Error, at index: Int = 0) async {
            requests[index].continuation.finish(throwing: error)
            while requests[index].result == nil { await Task.yield() }
        }
        
        func cancelPendingRequests() async throws {
            for (index, request) in requests.enumerated() where request.result == nil {
                request.continuation.finish(throwing: CancellationError())
                
                while requests[index].result == nil { await Task.yield() }
            }
        }
    } 
}
