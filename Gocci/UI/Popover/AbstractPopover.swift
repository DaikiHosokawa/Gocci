//
//  AbstractPopup.swift
//  Gocci
//
//  Created by Ma Wa on 29.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class AbstractPopover: UIViewController, UIPopoverPresentationControllerDelegate {
    
    
    private unowned let from: UIViewController
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported. You can't use this view controller in storyboards")
    }
    
    init(from: UIViewController, position: CGRect, widthRatio:CGFloat, heightRatio:CGFloat) {
        self.from = from
        super.init(nibName: String(self.dynamicType), bundle: nil)
        
        let width  = from.view.frame.width  * widthRatio  / 100
        let height = from.view.frame.height * heightRatio / 100

        self.modalPresentationStyle = .Popover
        self.preferredContentSize = CGSizeMake(width, height)
        
        self.popoverPresentationController?.permittedArrowDirections = .Any
        self.popoverPresentationController?.delegate = self
        self.popoverPresentationController?.sourceView = from.view
        self.popoverPresentationController?.sourceRect = position
    }
    
    // Needed to show real popover popups like on iPad. Without this all popovers are fullscreen. meh
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    func pop() {
        dispatch_async(dispatch_get_main_queue()){ // <- APPLE IOS BUG
            self.from.presentViewController(self, animated: true, completion: nil)
        }
    }
 

}


