//
//  File.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Observation
import ExpenseFeature

@MainActor
@Observable
public class SaveExpenseViewModel {
    public typealias Completion = () -> Void
    private let saveExpense: SaveExpense
    var errorMessage: String?
    var isLoading: Bool = false
    var completion: Completion
    
    public init(saveExpense: @escaping SaveExpense, completion: @escaping Completion) {
        self.saveExpense = saveExpense
        self.completion = completion
    }
    
    public func save(draft: DraftExpense) async {
        defer {
            isLoading = false
        }
        isLoading = true
        errorMessage = nil
        
        do {
            try await saveExpense(draft)
            completion() 
        } catch {
            errorMessage = "Failed to save expense. Please try again."
        }
    }
}
