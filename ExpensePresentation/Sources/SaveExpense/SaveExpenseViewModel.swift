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
    let saveExpenses: SaveExpense
    
    init(saveExpenses: @escaping SaveExpense) {
        self.saveExpenses = saveExpenses
    }
}
