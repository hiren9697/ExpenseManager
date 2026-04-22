//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 22/04/26.
//

import SwiftData

final public class SwiftDataStore: Sendable {
    let container: ModelContainer
    
    public init(container: ModelContainer) {
        self.container = container
    }
}

