//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 13/05/26.
//

import Testing
import ExpenseFeature
import ExpensePresentation
import ExpenseUI_UIKit

extension ExpensesViewControllerTests {
    func assertThat(_ sut: ExpensesViewController,
                    isRendering expenses: [Expense],
                    sourceLocation: SourceLocation = #_sourceLocation) {
        guard sut.numberOfRenderedExpenseViews() == expenses.count else {
            #expect(Bool(false),
                    "Expected \(expenses.count) expenses, got \(sut.numberOfRenderedExpenseViews()) instead.",
                    sourceLocation: sourceLocation)
            return
        }
        
        for (index, expense) in expenses.enumerated() {
            assertThat(sut,
                       hasViewConfiguredFor: expense,
                       at: index,
                       sourceLocation: sourceLocation)
        }
    }
    
    func assertThat(_ sut: ExpensesViewController,
                    hasViewConfiguredFor expense: Expense,
                    at index: Int,
                    sourceLocation: SourceLocation = #_sourceLocation) {
        let view = sut.expenseView(at: index)
        
        guard let cell = view as? ExpenseCell else {
            #expect(Bool(false),
                    "Expected \(ExpenseCell.self) instance, got \(String(describing: view)) instead",
                    sourceLocation: sourceLocation)
            return
        }
        
        let expectedViewModel = ExpenseViewModel(expense: expense)
        
        #expect(cell.titleText == expectedViewModel.title,
                "Expected title text to be \(expectedViewModel.title) for expense view at index (\(index))",
                sourceLocation: sourceLocation)
        #expect(cell.amountText == expectedViewModel.amountText,
                "Expected amount text to be \(expectedViewModel.amountText) for expense view at index (\(index))",
                sourceLocation: sourceLocation)
        #expect(cell.dateText == expectedViewModel.dateText,
                "Expected date text to be \(expectedViewModel.dateText) for expense view at index (\(index))",
                sourceLocation: sourceLocation)
    }
}
