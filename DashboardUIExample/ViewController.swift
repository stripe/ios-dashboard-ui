//
//  ViewController.swift
//  DashboardUIExample
//
//  Created by Ben Guo on 7/28/16.
//  Copyright © 2016 stripe. All rights reserved.
//

import UIKit
import StripeDashboardUI

class ViewController: UIViewController {

    @IBOutlet weak var moneyTextField: MoneyTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.moneyTextField.addTarget(self, action: #selector(amountChanged), forControlEvents: .ValueChanged)
        // Do any additional setup after loading the view, typically from a nib.
    }

    func tap() {
        self.moneyTextField.resignFirstResponder()
    }

    func amountChanged() {
        print(self.moneyTextField.amountString)
    }

}

