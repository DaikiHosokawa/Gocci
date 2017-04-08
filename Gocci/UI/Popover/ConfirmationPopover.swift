//
//  ConfirmationPopupController.swift
//  Gocci
//
//  Created by Ma Wa on 29.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit


class ConfirmationPopover: AbstractPopover {
    

    @IBOutlet weak var label: UILabel!
    
    var confirmationText = "Confirmation Text"
    var onCancel: ()->() = {}
    var onConfirm: ()->() = {}
 
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = confirmationText
    }
    
    @IBAction func confirmClicked(sender: AnyObject) {
        onConfirm()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        onCancel()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}