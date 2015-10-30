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
    
    

//                            [popoverController presentPopoverFromRect:[(UIButton *)sender frame]  inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    

    

    

}



/*   STPOPUP IMPLEMENTATION WHICH IS ALSO GOOD. DONT THROW THIS CODE AWAY

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
*/