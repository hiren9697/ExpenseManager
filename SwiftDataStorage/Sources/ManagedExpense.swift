//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 22/04/26.
//

import Foundation
import SwiftData

@Model
final class ManagedExpense { // Not public! Just internal to the infrastructure.
    @Attribute(.unique) var id: UUID
    var amount: Double
    var date: Date
    var note: String?
    
    init(id: UUID, amount: Double, date: Date, note: String? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }
}
