//
//  File.swift
//  SwiftDataStorage
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Foundation
import Testing
import SwiftDataStorage

extension ExpenseSwiftDataStoreTests {
    func compare(input: [LocalExpense], fetched: [LocalExpense], sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(input.count == fetched.count,
                "Expected list of expenses to have the same count as the fetched list",
                sourceLocation: sourceLocation)
        for (inputExpense, fetchedExpense) in zip(input, fetched) {
            compare(input: inputExpense, fetched: fetchedExpense, sourceLocation: sourceLocation)
        }
    }
    
    func compare(input: LocalExpense, fetched: LocalExpense, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(input.id == fetched.id, sourceLocation: sourceLocation)
        #expect(input.amount == fetched.amount, sourceLocation: sourceLocation)
        #expect(input.date == fetched.date, sourceLocation: sourceLocation)
        #expect(input.note == fetched.note, sourceLocation: sourceLocation)
    } 
}
