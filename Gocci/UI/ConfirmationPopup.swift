//
//  ConfirmationPopupController.swift
//  Gocci
//
//  Created by Ma Wa on 29.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit


class ConfirmationPopup: AbstractPopup {
    

    @IBOutlet weak var label: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Persistent Persistent Persistent Persistent Persistent Persistent Persistent Persistent Persistent "

    }
}