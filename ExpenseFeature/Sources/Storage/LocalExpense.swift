//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 28/04/26.
//

import Foundation
import SwiftData
import Domain

// This is a plain struct! It is automatically Sendable and thread-safe.
public struct LocalExpense: Equatable, Sendable {
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
