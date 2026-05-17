//
//  File.swift
//  SwiftDataStorage
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Foundation
import SwiftDataStorage

extension ExpenseSwiftDataStoreTests {
    func uniqueExpense(amount: Double = 1.0, date: Date = Date(), note: String? = nil) -> LocalExpense {
        LocalExpense(id: UUID(), amount: amount, date: date, note: note)
    }   
}

