//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 22/04/26.
//

import Foundation
import SwiftData
import Domain

extension SwiftDataStore {
    public func insert(expense: LocalExpense) async throws {
        // 1. Create a scratchpad tied to your container
        let context = ModelContext(container)
        
        // 2. Convert LocalExpense to ManagedExpense
        let managedExpense = ManagedExpense(id: expense.id,
                                            amount: expense.amount,
                                            date: expense.date,
                                            note: expense.note)
        
        // 3. Stage the new expense in the scratchpad
        context.insert(managedExpense)
        
        // 4. Explicitly save to write it to the database immediately
        try context.save()
    }
    
    public func fetch() async throws -> [LocalExpense] {
        let context = ModelContext(container)
        
        // FetchDescriptor is the query instructions (equivalent to NSFetchRequest)
        var descriptor = FetchDescriptor<ManagedExpense>()
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        
        let managedExpenses = try context.fetch(descriptor)
        
        return managedExpenses.map{ LocalExpense(id: $0.id, amount: $0.amount, date: $0.date, note: $0.note) }
    }
}
