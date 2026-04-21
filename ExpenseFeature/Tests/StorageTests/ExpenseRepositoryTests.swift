//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 21/04/26.
//

import Testing
import Storage

@Suite("Expense Repository Tests")
@MainActor
struct ExpenseRepositoryTests {
    @Test("Load delivers no expenses on an empty database")
    func load_deliversEmptyOnEmptyDatabase() async throws {
        try await makeSUT(action: { repository in
            // Your assertions will go here!
        })
    }
    
    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation, 
                         action: (ExpenseRepository) async throws -> Void) async throws {
        
        try await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let sut = ExpenseRepository()
            
            tracker(sut)
            
            try await action(sut)
        })
    }
}

