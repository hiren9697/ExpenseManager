//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 19/04/26.
//

import Foundation

public struct DraftExpense {
    public let amount: Double
    public let date: Date
    public let note: String?
    
    public init(amount: Double, date: Date, note: String?) {
        self.amount = amount
        self.date = date
        self.note = note
    }
}

public typealias SaveExpense = (DraftExpense) async throws -> Void
