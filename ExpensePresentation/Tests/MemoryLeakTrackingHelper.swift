//
//  File.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 02/05/26.
//

import Testing

private final class WeakReference {
    weak var object: AnyObject?
    init(_ object: AnyObject?) { self.object = object }
}

@MainActor
func withMainActorMemoryLeakTracking(sourceLocation: SourceLocation = #_sourceLocation,
                                     testBody: @MainActor (_ trackForMemoryLeaks: @MainActor (AnyObject?...) -> Void) async throws -> Void) async rethrows {
    var weakReferences: [WeakReference] = []
    let track: @MainActor (AnyObject?...) -> Void = { instances in
        weakReferences.append(contentsOf: instances.map(WeakReference.init))
    }
    
    try await testBody(track)
    
    for weakReference in weakReferences {
        #expect(weakReference.object == nil, "Potential memory leak.", sourceLocation: sourceLocation)
    }
}
