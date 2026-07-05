import Foundation
import Testing

extension SaveExpenseViewControllerTests {
    
    /// Deterministically polls the MainActor until the expected condition is met or times out.
    func assertEventually(
        timeout: TimeInterval = 0.5, // 0.5s is plenty for local UI/State hops
        _ condition: @MainActor () -> Bool,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        
        while Date() < deadline {
            if condition() { return } // Success: Exit instantly
            await Task.yield()        // Give the OS time to process the @Observable hop
        }
        
        Issue.record("Expected condition was not met within \(timeout) seconds", sourceLocation: sourceLocation)
    }
    
    func anyNSError() -> NSError { 
        NSError(domain: "any error", code: 0) 
    }
}
