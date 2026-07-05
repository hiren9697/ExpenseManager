import Foundation
@testable import ExpenseFeature

@MainActor
class SaveExpenseSpy: Sendable {
    enum Message { case save }
    private struct Request {
        let param: Message
        let stream: AsyncThrowingStream<Void, Error>
        let continuation: AsyncThrowingStream<Void, Error>.Continuation
        var result: Result<Void, Error>?
    }
    
    private var requests: [Request] = []
    var messages: [Message] { requests.map(\.param) }
    
    func saveExpense(_ draft: DraftExpense) async throws {
        let index = requests.count
        let (stream, continuation) = AsyncThrowingStream<Void, Error>.makeStream()
        requests.append(Request(param: .save, stream: stream, continuation: continuation))
        
        do {
            for try await _ in stream {
                requests[index].result = .success(())
                return
            }
            requests[index].result = .success(())
        } catch {
            requests[index].result = .failure(error)
            throw error
        }
    }
    
    func completeSaveAndWaitUntilConsumed(at index: Int = 0) async {
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
