//
//  Pop.swift
//  Gocci
//
//  Created by Ma Wa on 20.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    @nonobjc static var window: UIWindow? = nil // UIWindow(frame: UIScreen.mainScreen().bounds)
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIAlertController.window?.hidden = true
        UIAlertController.window = nil
        
    }

}

class Pop {
    
    
    
    class func show(title: String, _ msg: String) {
        
        //
        //            - (void)show:(BOOL)animated {
        //                self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        //                self.alertWindow.rootViewController = [[UIViewController alloc] init];
        //                self.alertWindow.windowLevel = UIWindowLevelAlert + 1;
        //                [self.alertWindow makeKeyAndVisible];
        //                [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
        //                }
        //
        //                - (void)viewDidDisappear:(BOOL)animated {
        //                    [super viewDidDisappear:animated];
        //
        //                    // precaution to insure window gets destroyed
        //                    self.alertWindow.hidden = YES;
        //                    self.alertWindow = nil;
        
        //        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        UIAlertController.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        UIAlertController.window?.rootViewController = UIViewController()
        UIAlertController.window?.windowLevel = UIWindowLevelAlert + 1
        UIAlertController.window?.makeKeyAndVisible()
        
        let alert = UIAlertController(title: "Hello!", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.Destructive) { _ in
            //alertWindow.hidden = true
        })
//        alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) { _ in
//            alertWindow.hidden = true
//        })
//        alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.Cancel) { _ in
//            alertWindow.hidden = true
//        })
        
        
        UIAlertController.window?.rootViewController!.presentViewController(alert, animated: true) { () -> Void in }
        
        
    }

}