import UIKit
import Observation
import ExpensePresentation

public class SaveExpenseViewController: UIViewController {
    let viewModel: SaveExpenseViewModel
    let formatDate: ((Date) -> String)?
    
    public let amountTextField = UITextField()
    public let dateTextField = UITextField()
    public let noteTextField = UITextField()
    public let saveButton = UIButton(type: .system)
    public let errorLabel = UILabel()
    public let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let datePicker = UIDatePicker()
    
    public init(viewModel: SaveExpenseViewModel, formatDate: ((Date) -> String)? = nil) {
        self.viewModel = viewModel
        self.formatDate = formatDate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.cancel()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupToolbars()
        setupBindings()
        renderState()
        observeViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        amountTextField.borderStyle = .roundedRect
        amountTextField.placeholder = "Amount"
        amountTextField.keyboardType = .decimalPad
        
        dateTextField.borderStyle = .roundedRect
        dateTextField.placeholder = "Date"
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = viewModel.date
        dateTextField.inputView = datePicker
        updateDateTextField()
        
        noteTextField.borderStyle = .roundedRect
        noteTextField.placeholder = "Note (Optional)"
        
        saveButton.setTitle("Save", for: .normal)
        
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        
        let stack = UIStackView(arrangedSubviews: [amountTextField, dateTextField, noteTextField, saveButton, errorLabel, activityIndicator])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupToolbars() {
        // Amount Toolbar
        let amountToolbar = UIToolbar()
        amountToolbar.sizeToFit()
        let nextToDateButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(focusDateTextField))
        amountToolbar.items = [.flexibleSpace(), nextToDateButton]
        amountTextField.inputAccessoryView = amountToolbar
        
        // Date Toolbar
        let dateToolbar = UIToolbar()
        dateToolbar.sizeToFit()
        let nextToNoteButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(focusNoteTextField))
        dateToolbar.items = [.flexibleSpace(), nextToNoteButton]
        dateTextField.inputAccessoryView = dateToolbar
        
        // Note Toolbar
        let noteToolbar = UIToolbar()
        noteToolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .prominent, target: self, action: #selector(dismissKeyboard))
        noteToolbar.items = [.flexibleSpace(), doneButton]
        noteTextField.inputAccessoryView = noteToolbar
    }
    
    private func setupBindings() {
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        noteTextField.addTarget(self, action: #selector(noteChanged), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func observeViewModel() {
        withObservationTracking {
            _ = viewModel.isLoading
            _ = viewModel.errorMessage
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.renderState()
                self?.observeViewModel()
            }
        }
    }
    
    private func renderState() {
        let isLoading = viewModel.isLoading
        let errorMessage = viewModel.errorMessage
        
        if isLoading {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        
        self.errorLabel.text = errorMessage
        self.errorLabel.isHidden = (errorMessage == nil)
        self.saveButton.isEnabled = !isLoading
    }
    
    private func updateDateTextField() {
        dateTextField.text = formatDate?(viewModel.date) ?? ""
    }
    
    @objc private func amountChanged() {
        viewModel.amountText = amountTextField.text ?? ""
    }
    
    @objc private func noteChanged() {
        viewModel.note = noteTextField.text ?? ""
    }
    
    @objc private func dateChanged() {
        viewModel.date = datePicker.date
        updateDateTextField()
    }
    
    @objc private func saveTapped() {
        Task { [weak self] in
            await self?.viewModel.save()
        }
    }
    
    @objc private func focusDateTextField() {
        dateTextField.becomeFirstResponder()
    }
    
    @objc private func focusNoteTextField() {
        noteTextField.becomeFirstResponder()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
