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
        private enum AsyncResult {
            case success
            case failure
            case cancelled
        }
        enum Message { 
            case loadExpenses 
        }
        private struct Request {
            let param: Message
            let stream: AsyncThrowingStream<[Expense], Error>
            let continuation: AsyncThrowingStream<[Expense], Error>.Continuation
            var result: AsyncResult?
        }
        private struct NoResponse: Error {}
        private struct Timeout: Error {}
        
        private var requests: [Request] = []
        
        var messages: [Message] { requests.map(\.param) }
        
        func loadExpenses() async throws -> [Expense] {
            let index = requests.count
            let (stream, continuation) = AsyncThrowingStream<[Expense], Error>.makeStream()
            requests.append(Request(param: Message.loadExpenses, stream: stream, continuation: continuation))
            
            do {
                for try await result in stream {
                    try Task.checkCancellation()
                    requests[index].result = .success
                    return result
                }
                
                try Task.checkCancellation()
                
                throw NoResponse()
            } catch {
                requests[index].result = Task.isCancelled ? .cancelled : .failure
                throw error
            }
        }
        
        func completeExpensesLoadingAndWaitUntilConsumed(with expenses: [Expense] = [], at index: Int = 0) async {
            requests[index].continuation.yield(expenses)
            requests[index].continuation.finish()
            while requests[index].result == nil { await Task.yield() }
        }
        
        func completeExpensesLoadingWithErrorAndWaitUntilConsumed(_ error: Error, at index: Int = 0) async {
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
