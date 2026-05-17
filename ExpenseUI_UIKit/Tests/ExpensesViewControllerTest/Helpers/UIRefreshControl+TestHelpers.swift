//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 13/05/26.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
