//
//  INAutoResizeLabel.swift
//  Gocci
//
//  Created by Markus Wanke on 19.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

class INAutoResizeLabel: UILabel {
    
    var onlyOnceToken: dispatch_once_t = 0
    
    override func drawRect(rect: CGRect) {

        dispatch_once(&onlyOnceToken) {
            
            self.adjustsFontSizeToFitWidth = true;
            
            if let usedFont:UIFont = self.font {
                
                self.adjustsFontSizeToFitWidth = true;
                print(UIScreen.mainScreen().bounds)
                
                // true if not a 'plus' iPhone
                if(UIScreen.mainScreen().bounds.width < 414) {
                    // TODO find the optimal formula on how to reduze fontsize, based on width
                    self.font = UIFont(name: usedFont.fontName, size: usedFont.pointSize - 5)
                }
            }
        }
        
        super.drawRect(rect)
    }
}