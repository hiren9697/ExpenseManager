//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 13/05/26.
//

import UIKit
import ExpenseUI_UIKit

extension ExpensesViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func prepareForFirstAppearance() {
        // setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17PlusSupport()
    }
    
    /*
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
     */
    
    private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
        let fakeRefreshControl = FakeUIRefreshControl()
        
        tableView.refreshControl?.allTargets.forEach { target in
            tableView.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        tableView.refreshControl = fakeRefreshControl
    }
    
    private class FakeUIRefreshControl: UIRefreshControl {
        private var _isRefreshing = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
    
    func simulateUserInitiatedReload() {
        tableView.refreshControl?.simulatePullToRefresh()
    }
    
    func simulateErrorViewRetryAction() {
        errorView.retryButton.simulateTap()
    }
    
    var isShowingLoadingIndicator: Bool {
        return tableView.refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedExpenseViews() -> Int {
        return tableView.numberOfRows(inSection: expenseSection)
    }
    
    func expenseView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: expenseSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var expenseSection: Int { 0 }
}

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
