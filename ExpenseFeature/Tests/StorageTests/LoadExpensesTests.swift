//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 26/04/26.
//

import Foundation
import Testing
import SwiftData
import Domain
@testable import Storage

@Suite("Expense Repository Tests")
@MainActor
struct LoadExpenseTests {
    
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
        let today = Date()
        let firstExpense = uniqueExpense(date: today.adding(seconds: 1)) // Most recent
        let secondExpense = uniqueExpense(amount: 2, date: today, note: "Second expense note") // Older
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
    
    @Test("Load delivers expenses sorted by date (most recent first)")
    func load_deliversExpenses_sortedByDate() async throws {
        // Arrange
        let today = Date()
        let olderExpense = uniqueExpense(date: today.adding(days: -1), note: "older")
        let middleExpense = uniqueExpense(date: today, note: "middle")
        let newestExpense = uniqueExpense(date: today.adding(days: 1), note: "newest")
        
        try await makeSUT(action: { store in
            // Act
            // Insert in a random order
            try await store.insert(expense: middleExpense)
            try await store.insert(expense: newestExpense)
            try await store.insert(expense: olderExpense)
            
            let fetchedExpenses = try await store.fetch()
            
            // Assert
            compare(input: [newestExpense, middleExpense, olderExpense], fetched: fetchedExpenses)
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
    
    private func uniqueExpense(amount: Double = 1.0, date: Date = Date(), note: String? = nil) -> LocalExpense {
        LocalExpense(id: UUID(), amount: amount, date: date, note: note)
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

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
