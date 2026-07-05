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
    public var errorMessage: String?
    public var isLoading: Bool = false
    public var amountText: String = ""
    public var date: Date
    public var note: String = ""
    private var completion: Completion
    nonisolated(unsafe) private var saveTask: Task<Void, Never>?
    
    public init(saveExpense: @escaping SaveExpense, currentDate: Date = .now, completion: @escaping Completion) {
        self.saveExpense = saveExpense
        self.date = currentDate
        self.completion = completion
    }
    public static let saveErrorMessage = "Failed to save expense. Please try again."
    public static let invalidInputMessage = "Please enter a valid amount greater than zero."
    
    nonisolated public func cancel() {
        saveTask?.cancel()
    }
    
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
        
        
        saveTask = Task {
            do {
                try await saveExpense(draft)
                if !Task.isCancelled {
                    completion()
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = Self.saveErrorMessage
                }
            }
        }
        await saveTask?.value
    }
}
