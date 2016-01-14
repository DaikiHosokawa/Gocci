//
//  OverlayWindow.swift
//  Gocci
//
//  Created by Ma Wa on 24.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class OverlayWindow {
    
    static var window: UIWindow! = nil
    
    class func oneTimeViewController(userSpaceFunction: UIViewController -> () ) {
        
        Util.runOnMainThread {
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            
            //window.windowLevel = UIWindowLevelAlert + 1
            //window.backgroundColor = UIColor.purpleColor()
            
            let ovc = OverlayViewController(nibName: nil, bundle: nil)
            ovc.view.backgroundColor = UIColor.clearColor()
            
            ovc.cleanUp = {
                Util.runOnMainThread {
                    //window.rootViewController = nil
                    window.hidden = true
                    window = nil
                }
            }
            
            ovc.whenReady = userSpaceFunction
                
            window.rootViewController = ovc
            
            window.makeKeyAndVisible()
            
        }
    }
    
    
    
    class OverlayViewController: UIViewController {
        
        var whenReady: (UIViewController->())? = nil
        var cleanUp: ()->() = {}
        
        override func viewWillAppear(animated: Bool) {
//            Lo.error("BEFORE OverlayViewController: viewDidLoad")
            super.viewWillAppear(animated)
            
            if whenReady == nil {
                cleanUp()
            }
            //Lo.error("AFTER  OverlayViewController: viewDidLoad")
        }
        
        override func viewDidAppear(animated: Bool) {
//            Lo.error("BEFORE OverlayViewController: viewDidAppear")
            super.viewDidAppear(animated)
            
            if let showOverLayUserStuff = whenReady {
                whenReady = nil
                showOverLayUserStuff(self)
            }
            
            //Lo.error("AFTER  OverlayViewController: viewDidAppear")
        }
        
//        override func viewWillDisappear(animated: Bool) {
//            Lo.error("BEFORE OverlayViewController: viewWillDisappear")
//            super.viewWillDisappear(animated)
//            //Lo.error("AFTER  OverlayViewController: viewWillDisappear")
//        }
//        
//        override func viewDidDisappear(animated: Bool) {
//            Lo.error("BEFORE OverlayViewController: viewDidDisappear")
//            super.viewDidDisappear(animated)
//            //Lo.error("AFTER  OverlayViewController: viewDidDisappear")
//        }
        
    }
}

