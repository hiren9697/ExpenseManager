//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import UIKit
import ExpensePresentation

public class SaveExpenseViewController: UIViewController {
    let viewModel: SaveExpenseViewModel
    
    init(viewModel: SaveExpenseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
