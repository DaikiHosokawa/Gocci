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

    func join(parts: [String]) -> String {
        return parts.joinWithSeparator(self)
    }
    
    func asUTF8Data() -> NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding) ?? "ERROR: immpossible to convert to utf8 data".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func percentEncodingHTML5Style() -> String {
        // HTML5 standart escaping
        let betterSafeThanSorry = ".-_*ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzyz"
        let secureSet = NSCharacterSet(charactersInString:betterSafeThanSorry)
        return self.stringByAddingPercentEncodingWithAllowedCharacters(secureSet)! // ?? "ERROR: unescapeable"
    }
}

extension NSData {
    func asUTF8String() -> String {
        return String(data: self, encoding: NSUTF8StringEncoding) ?? "ERROR: immpossible to convert to utf8 data"
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
