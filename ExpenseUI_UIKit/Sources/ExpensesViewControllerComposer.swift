//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 03/05/26.
//

import ExpensePresentation

@MainActor
public enum ExpensesViewControllerComposer {
    public static func compose(viewModel: ExpensesViewModel) -> ExpensesViewController {
        let viewController = ExpensesViewController(viewModel: viewModel)
        return viewController
    }
}
