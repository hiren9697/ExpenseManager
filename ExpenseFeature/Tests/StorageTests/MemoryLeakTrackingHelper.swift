//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 20/04/26.
//

import Testing

private final class WeakReference {
    weak var object: AnyObject?
    init(_ object: AnyObject?) { self.object = object }
}

@MainActor
func withMemoryLeakTracking(sourceLocation: SourceLocation = #_sourceLocation,
                            // The tracker is sync, but the testBody is async throws!
                            testBody: @MainActor (_ trackForMemoryLeaks: (AnyObject?...) -> Void) async throws -> Void) async rethrows {
    
    var weakReferences: [WeakReference] = []
    let track: (AnyObject?...) -> Void = { instances in
        weakReferences.append(contentsOf: instances.map(WeakReference.init))
    }
    
    // We must await the test body
    try await testBody(track)
    
    for weakReference in weakReferences {
        #expect(weakReference.object == nil, "Potential memory leak.", sourceLocation: sourceLocation)
    }
}

