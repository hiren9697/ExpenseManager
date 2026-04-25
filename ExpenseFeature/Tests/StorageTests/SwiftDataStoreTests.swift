//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 22/04/26.
//

import Foundation
import Testing
import SwiftData
import Domain
@testable import Storage

@Suite("Expense Repository Tests")
@MainActor
struct ExpenseSwiftDataStoreTests {
    
    @Test("Load delivers no expenses on an empty database")
    func load_deliversEmpty_onEmptyDatabase() async throws {
        // Arrange
        try await makeSUT(action: { store in
            // Act
            let expenses = try await store.fetch()
            // Assert
            #expect(expenses.isEmpty)
        })
    }
    
    @Test("Load delivers expenses on a non-empty database")
    func load_deliversExpenses_onNonEmptyDatabase() async throws {
        // Arrange
        let firstExpense = LocalExpense(id: UUID(), amount: 1, date: Date(), note: nil)
        let secondExpense = LocalExpense(id: UUID(), amount: 2, date: Date(), note: "Second expense note")
        try await makeSUT(action: { store in
            // Act
            try await store.insert(expense: firstExpense)
            let firstFetchAttempExpenses = try await store.fetch()
            
            // Assert
            compare(input: [firstExpense], fetched: firstFetchAttempExpenses)
            
            // Act
            try await store.insert(expense: secondExpense)
            let secondFetchAttempExpenses = try await store.fetch()
            
            // Assert
            compare(input: [firstExpense, secondExpense], fetched: secondFetchAttempExpenses)
        })
    }
    
    @Test("Insert updates existing record on duplicate ID")
    func insert_updatesExistingRecord_onDuplicate() async throws {
        // Arrange
        let sharedId = UUID()
        let firstExpense = LocalExpense(id: sharedId, amount: 10, date: Date(), note: "First")
        let duplicateExpense = LocalExpense(id: sharedId, amount: 20, date: Date(), note: "Duplicate")
        
        try await makeSUT(action: { store in
            try await store.insert(expense: firstExpense)
            
            // Act
            try await store.insert(expense: duplicateExpense)
            
            //  Assert
            let expenses = try await store.fetch()
            #expect(expenses.count == 1, "Expected only 1 expense after upsert")
            #expect(expenses.first?.amount == 20, "Expected amount to be updated")
            #expect(expenses.first?.note == "Duplicate", "Expected note to be updated")
        })
    }
    
    // MARK: - Helpers
    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation,
                         action: @MainActor (SwiftDataStore) async throws -> Void) async throws {
        try await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let container = try ModelContainer(for: ManagedExpense.self,
                                               configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            let sut = SwiftDataStore(container: container)
            
            tracker(sut)
            
            try await action(sut)
        })
    }
    
    private func compare(input: [LocalExpense], fetched: [LocalExpense], sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(input.count == fetched.count,
                "Expected list of expenses to have the same count as the fetched list",
                sourceLocation: sourceLocation)
        for (inputExpense, fetchedExpense) in zip(input, fetched) {
            compare(input: inputExpense, fetched: fetchedExpense, sourceLocation: sourceLocation)
        }
    }
    
    private func compare(input: LocalExpense, fetched: LocalExpense, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(input.id == fetched.id, sourceLocation: sourceLocation)
        #expect(input.amount == fetched.amount, sourceLocation: sourceLocation)
        #expect(input.date == fetched.date, sourceLocation: sourceLocation)
        #expect(input.note == fetched.note, sourceLocation: sourceLocation)
    }
}


