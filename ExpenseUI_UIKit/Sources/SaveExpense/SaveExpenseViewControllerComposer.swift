//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Foundation
import ExpenseFeature
import ExpensePresentation

@MainActor
public class SaveExpenseViewControllerComposer {
    public static func compose(saveExpense: @escaping SaveExpense,
                               currentDateGeneragor: @escaping () -> Date, 
                               completion: @escaping () -> Void) -> SaveExpenseViewController {
        return SaveExpenseViewController(viewModel: SaveExpenseViewModel(saveExpense: saveExpense,
                                                                         currentDateGenerator: currentDateGeneragor,
                                                                         completion: completion))
    }
}
