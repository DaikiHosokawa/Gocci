//
//  AbstractPopup.swift
//  Gocci
//
//  Created by Ma Wa on 30.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class AbstractPopup: UIViewController
{
    private unowned let from: UIViewController
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported. You can't use this view controller in storyboards")
    }
    
    init(from: UIViewController, title: String, widthRatio:CGFloat, heightRatio:CGFloat) {
        self.from = from
        super.init(nibName: String(self.dynamicType), bundle: nil)
        
        let width  = from.view.frame.width  * widthRatio  / 100
        let height = from.view.frame.height * heightRatio / 100
        
        self.contentSizeInPopup = CGSize(width: width, height: height)
        self.landscapeContentSizeInPopup = CGSize(width: height, height: width)
        
        self.title = title;
    }

    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pop() {
        
        let popup = STPopupController(rootViewController: self)
        popup.cornerRadius = 4
        popup.transitionStyle = STPopupTransitionStyle.Fade
        STPopupNavigationBar.appearance().barTintColor = UIColor(red: 247.0/255.0, green: 85.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        STPopupNavigationBar.appearance().tintColor = UIColor.whiteColor()
        STPopupNavigationBar.appearance().barStyle = UIBarStyle.Default
        //        STPopupNavigationBar.appearance().titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
        
        //
        //            [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil, nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:17] } forState:UIControlStateNormal];
        
        
        popup.presentInViewController(from)
    }
}
