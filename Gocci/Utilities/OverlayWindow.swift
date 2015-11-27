//
//  OverlayWindow.swift
//  Gocci
//
//  Created by Ma Wa on 24.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class OverlayWindow {
    
    //@nonobjc static var window: UIWindow? = nil // UIWindow(frame: UIScreen.mainScreen().bounds)
    
    
//    class SpecialViewController: UIViewController {
//        override func viewWillAppear(animated: Bool) {
//            <#code#>
//        }
//    }
    
    class func show(fromOverlay: (viewController: UIViewController, hideAgain: ()->() ) -> () ) {
        
        var window: UIWindow? = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window!.windowLevel = UIWindowLevelAlert + 1
        window!.rootViewController = UIViewController(nibName: nil, bundle: nil)
        window!.makeKeyAndVisible()
        
        
        fromOverlay(viewController: window!.rootViewController!) {
            window!.hidden = true
            window = nil
        }
    }
        
}