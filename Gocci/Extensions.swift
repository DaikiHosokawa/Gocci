//
//  Extensions.swift
//  Gocci
//
//  Created by Markus Wanke on 16.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



// I have no Idea if this is a good idea, but we can save some ugly interfacecode with that.
// But it likly to cause problems in the future
extension UIApplication {
    class func visibleViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return visibleViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.visibleViewController where top.view.window != nil {
                return visibleViewController(top)
            } else if let selected = tab.selectedViewController {
                return visibleViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return visibleViewController(presented)
        }
        
        return base
    }
}