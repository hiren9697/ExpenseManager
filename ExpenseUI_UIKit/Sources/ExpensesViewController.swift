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
public class ExpensesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let viewModel: ExpensesViewModel
    private var onViewAppearance: (() -> Void)?

    public let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    public let errorView: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    public let emptyView: EmptyView = {
        let view = EmptyView(message: "No expenses found.")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    public init(viewModel: ExpensesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(errorView)
        view.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        errorView.onRetry = { [weak self] in
            self?.loadExpenses()
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExpenseCell.self, forCellReuseIdentifier: "ExpenseCell")
    }

    private func setupBindings() {
        withObservationTracking {
            _ = viewModel.state
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.renderState()
                self?.setupBindings()
            }
        }
    }

    private func renderState() {
        tableView.reloadData()
        
        // Default to hidden
        tableView.isHidden = true
        errorView.isHidden = true
        emptyView.isHidden = true
        
        switch viewModel.state {
        case .notInitiated, .initialRequestInProgress:
            tableView.isHidden = false
        case .refreshInProgress, .nextPageInProgress:
            tableView.isHidden = false
        case .finishedWithData(let expenses):
            if expenses.isEmpty {
                emptyView.isHidden = false
            } else {
                tableView.isHidden = false
            }
        case .finishedWithError(let error):
            errorView.setupContent(image: nil, message: error)
            errorView.isHidden = false
        }
    }

    private func setupOnViewAppearance() {
        onViewAppearance = { [weak self] in
            self?.loadExpenses()
            self?.onViewAppearance = nil
        }
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refresh() {
        tableView.refreshControl?.beginRefreshing()
        Task {
            await viewModel.refresh()
            tableView.refreshControl?.endRefreshing()
        }
    }

    private func loadExpenses() {
        tableView.refreshControl?.beginRefreshing()
        Task {
            await viewModel.load()
            tableView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - TableView DataSource
extension ExpensesViewController {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.expenses?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! ExpenseCell
        if let expenseVM = viewModel.expenses?[indexPath.row] {
            cell.titleLabel.text = expenseVM.title
            cell.amountLabel.text = expenseVM.amountText
            cell.dateLabel.text = expenseVM.dateText
        }
        return cell
    }
}
