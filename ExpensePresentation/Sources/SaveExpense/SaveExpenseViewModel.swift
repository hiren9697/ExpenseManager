//
//  File.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Foundation
import Observation
import ExpenseFeature

@MainActor
@Observable
public class SaveExpenseViewModel {
    public typealias Completion = () -> Void
    private let saveExpense: SaveExpense
    var errorMessage: String?
    var isLoading: Bool = false
    var amountText: String = ""
    var date: Date
    var note: String = ""
    var completion: Completion
    
    public init(saveExpense: @escaping SaveExpense, currentDate: Date = .now, completion: @escaping Completion) {
        self.saveExpense = saveExpense
        self.date = currentDate
        self.completion = completion
    }
    public static let saveErrorMessage = "Failed to save expense. Please try again."
    public static let invalidInputMessage = "Please enter a valid amount greater than zero."
    
    public func save() async {
        let trimmedAmountText = amountText.trimmingCharacters(in: .whitespaces)
        guard let amount = Double(trimmedAmountText), amount > 0 else {
            errorMessage = Self.invalidInputMessage
            return
        }
        
        defer {
            isLoading = false
        }
        isLoading = true
        errorMessage = nil
        
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
        let finalNote = trimmedNote.isEmpty ? nil : trimmedNote
        let draft = DraftExpense(amount: amount, date: date, note: finalNote)
        
        do {
            try await saveExpense(draft)
            completion() 
        } catch {
            errorMessage = Self.saveErrorMessage
        }
    }
}
