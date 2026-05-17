//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 13/05/26.
//

import Foundation
import ExpenseFeature

extension ExpensesViewControllerTests {
    func waitForNetworkRequestToFire() async {
        await Task.yield()
    }
    
    func waitForUIUpdate() async {
        await Task.yield()
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    func makeExpense(amount: Double = 100, date: Date = Date(), note: String? = nil) -> Expense {
        return Expense(id: UUID(), amount: amount, date: date, note: note)
    }
}
