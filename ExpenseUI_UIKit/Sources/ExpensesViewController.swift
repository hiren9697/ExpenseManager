//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 03/05/26.
//

import UIKit
import ExpensePresentation

@MainActor
public class ExpensesViewController: UITableViewController {
    private let viewModel: ExpensesViewModel
    private var onViewAppearance: (() -> Void)?

    public init(viewModel: ExpensesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        setupOnViewAppearance()
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewAppearance?()
    }
}

// MARK: - Helpers
extension ExpensesViewController {
    private func setupOnViewAppearance() {
        onViewAppearance = { [weak self] in
            self?.fetchExpenses()
            self?.onViewAppearance = nil
        }
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    @objc func refresh() {
        fetchExpenses()
    }

    private func fetchExpenses() {
        Task {
            await viewModel.fetch()
        }
    }
}
