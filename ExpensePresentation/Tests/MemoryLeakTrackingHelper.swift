//
//  File.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 02/05/26.
//

import Foundation
import Testing

private final class WeakReference: @unchecked Sendable {
    weak var object: AnyObject?
    init(_ object: AnyObject?) { self.object = object }
}

private actor LeakTracker {
    var references: [WeakReference] = []
    
    func add(_ weakRefs: [WeakReference]) {
        references.append(contentsOf: weakRefs)
    }
}

func withMemoryLeakTracking(sourceLocation: SourceLocation = #_sourceLocation,
                            isolation: isolated (any Actor)? = #isolation,
                            testBody: (_ trackForMemoryLeaks: @Sendable @escaping (AnyObject?...) async -> Void) async -> Void) async {
    let tracker = LeakTracker()
    let track: @Sendable (AnyObject?...) async -> Void = { instances in
        let weakRefs = instances.map(WeakReference.init)
        await tracker.add(weakRefs)
    }
    
    await testBody(track)
    
    for weakReference in await tracker.references {
        #expect(weakReference.object == nil, "Potential memory leak.", sourceLocation: sourceLocation)
    }
}
