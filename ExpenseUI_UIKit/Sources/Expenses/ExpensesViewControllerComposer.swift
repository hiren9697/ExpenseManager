//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 03/05/26.
//

import ExpenseFeature
import ExpensePresentation

@MainActor
public enum ExpensesViewControllerComposer {
    public static func compose(loadExpenses: @escaping LoadExpenses) -> ExpensesViewController {
        let viewModel = ExpensesViewModel(loadExpenses: loadExpenses)
        let viewController = ExpensesViewController(viewModel: viewModel)
        return viewController
    }
}
