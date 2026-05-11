//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 03/05/26.
//

import UIKit
import Observation
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
        setupTableView()
        setupRefreshControl()
        setupOnViewAppearance()
        setupBindings()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewAppearance?()
    }
}

// MARK: - Helpers
extension ExpensesViewController {
    private func setupTableView() {
        tableView.register(ExpenseCell.self, forCellReuseIdentifier: "ExpenseCell")
    }

    private func setupBindings() {
        withObservationTracking {
            _ = viewModel.expenses
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.tableView.reloadData()
                self?.setupBindings()
            }
        }
    }

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
        refreshControl?.beginRefreshing()
        Task {
            await viewModel.fetch()
            refreshControl?.endRefreshing()
        }
    }
}

// MARK: - TableView DataSource
extension ExpensesViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.expenses?.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! ExpenseCell
        if let expenseVM = viewModel.expenses?[indexPath.row] {
            cell.titleLabel.text = expenseVM.title
            cell.amountLabel.text = expenseVM.amountText
            cell.dateLabel.text = expenseVM.dateText
        }
        return cell
    }
}
