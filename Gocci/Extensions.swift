//
//  Extensions.swift
//  Gocci
//
//  Created by Markus Wanke on 16.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


extension String {
    var length : Int {
        return self.characters.count
    }
}

extension NSUserDefaults {
    func setString(string: String!, forKey: String) {
        self.setValue(string, forKey: forKey)
    }
}

extension UIViewController {
    func ignoreCommonSenseAndGoToViewControllerWithName(tvcn: String) {
        let stobo = UIStoryboard(name: Util.getInchString(), bundle: nil)
        let vc = stobo.instantiateViewControllerWithIdentifier(tvcn)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func ignoreCommonSenseAndGoToInitialController() {
        let stobo = UIStoryboard(name: Util.getInchString(), bundle: nil)
        let vc = stobo.instantiateInitialViewController()
        self.presentViewController(vc!, animated: true, completion: nil)
    }
}

extension CGRect {
    func makeScale(widthDiff widthDiff: Int, heightDiff: Int) -> CGRect {
        return CGRect(origin: self.origin, size: CGSize(width: self.width + CGFloat(widthDiff), height: self.height + CGFloat(heightDiff)))
    }
}

extension CGSize {
    func makeScale(widthDiff widthDiff: Int, heightDiff: Int) -> CGSize {
        return CGSize(width: self.width + CGFloat(widthDiff), height: self.height + CGFloat(heightDiff))
    }
}
