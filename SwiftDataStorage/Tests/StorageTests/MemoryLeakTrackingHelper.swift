//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 21/04/26.
//

import Testing

private final class WeakReference {
    weak var object: AnyObject?
    init(_ object: AnyObject?) { self.object = object }
}

func withMemoryLeakTracking(sourceLocation: SourceLocation = #_sourceLocation,
                            testBody: (_ trackForMemoryLeaks: (AnyObject?...) -> Void) -> Void) {
    var weakReferences: [WeakReference] = []
    let track: (AnyObject?...) -> Void = { instances in
        weakReferences.append(contentsOf: instances.map(WeakReference.init))
    }
    
    testBody(track)
    
    for weakReference in weakReferences {
        #expect(weakReference.object == nil, "Potential memory leak.", sourceLocation: sourceLocation)
    }
}

func withMemoryLeakTracking(sourceLocation: SourceLocation = #_sourceLocation,
                            testBody: (_ trackForMemoryLeaks: (AnyObject?...) -> Void) async throws -> Void) async rethrows {
    var weakReferences: [WeakReference] = []
    let track: (AnyObject?...) -> Void = { instances in
        weakReferences.append(contentsOf: instances.map(WeakReference.init))
    }
    
    try await testBody(track)
    
    for weakReference in weakReferences {
        #expect(weakReference.object == nil, "Potential memory leak.", sourceLocation: sourceLocation)
    }
}
