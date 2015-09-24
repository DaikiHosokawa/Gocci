//
//  ReLoginViewController.swift
//  Gocci
//
//  Created by Ma Wa on 24.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

class ReLoginViewController : UIViewController {
    
    @IBOutlet weak var usernameEditFiled: UITextField!
    
    @IBOutlet weak var passwordEditField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginClicked(sender: AnyObject) {
        print("login clicked")
        print("username: \(usernameEditFiled.text)")
        print("password: \(passwordEditField.text)")
    }

    @IBAction func facebookLoginClicked(sender: AnyObject) {
        print("fb")
    }
    
    @IBAction func twitterLoginClicked(sender: AnyObject) {
        print("twit")
    }

}