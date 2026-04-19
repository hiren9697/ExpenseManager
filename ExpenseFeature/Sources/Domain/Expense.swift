//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 19/04/26.
//

import Foundation

public struct Expense: Equatable {
    public let id: UUID
    public let amount: Double
    public let date: Date
    public let note: String?
    
    public init(id: UUID, amount: Double, date: Date, note: String?) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }
}
