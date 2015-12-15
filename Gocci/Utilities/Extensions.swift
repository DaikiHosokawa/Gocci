//
//  Extensions.swift
//  Gocci
//
//  Created by Markus Wanke on 16.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit


extension String {
    
    func matches(re: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: re, options: [])
        return regex.firstMatchInString(self, options:[], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    var length : Int {
        return self.characters.count
    }

    func join(parts: [String]) -> String {
        return parts.joinWithSeparator(self)
    }
    
    func asUTF8Data() -> NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding) ?? "ERROR: immpossible to convert to utf8 data".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func brackify() -> String {
        return "\"" + self + "\""
    }
    
    func asURL() -> NSURL {
        return NSURL.fileURLWithPath(self)
    }
    
    func percentEncodingSane() -> String {
        let betterSafeThanSorry = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzyz"
        let secureSet = NSCharacterSet(charactersInString:betterSafeThanSorry)
        return self.stringByAddingPercentEncodingWithAllowedCharacters(secureSet)! // ?? "ERROR: unescapeable"
    }
    
    func percentEncodingHTML5Style() -> String {
        // HTML5 standart escaping
        let betterSafeThanSorry = ".-_*ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzyz"
        let secureSet = NSCharacterSet(charactersInString:betterSafeThanSorry)
        return self.stringByAddingPercentEncodingWithAllowedCharacters(secureSet)! // ?? "ERROR: unescapeable"
    }
    
    func percentEncodingOAuthStyle() -> String {
        let betterSafeThanSorry = ".-_~ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzyz"
        let secureSet = NSCharacterSet(charactersInString:betterSafeThanSorry)
        return self.stringByAddingPercentEncodingWithAllowedCharacters(secureSet)! // ?? "ERROR: unescapeable"
    }
}


extension NSData {
    func asUTF8String() -> String {
        return String(data: self, encoding: NSUTF8StringEncoding) ?? "ERROR: immpossible to convert to utf8 data"
    }
    
    func ppJSON() -> String {
        return JSON(data: self).rawString() ?? "Can't decode NSData to pretty JSON string"
    }
    
    func splitIntoChunksWithSize(chunkSize: Int) -> [NSData] {
        
        assert(chunkSize > 0, "Can't split NSData to chunks with zero or negative size")
        
        var ranges: [NSRange] = []
        
        var processedBytes = 0
        while(processedBytes < self.length) {
            var over = self.length - processedBytes
            if over > chunkSize {
                over = chunkSize
            }
            ranges.append(NSMakeRange(processedBytes, over))
            processedBytes += over
        }
        
        return ranges.map{ range in self.subdataWithRange(range) }
    }
}

extension NSUserDefaults {
    func setString(string: String!, forKey: String) {
        self.setValue(string, forKey: forKey)
    }
}

extension UIViewController {
    
    func simplePopup(title: String, _ msg: String, _ button: String, and: (()->())? = nil) {
        let p = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        p.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.Default, handler: { _ in and?() } ))
        self.presentViewController(p, animated: true, completion: nil)
    }
    
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


extension UIAlertController {
    
    @nonobjc static var window: UIWindow? = nil // UIWindow(frame: UIScreen.mainScreen().bounds)
    
    override public func viewDidDisappear(animated: Bool) {
        
        UIAlertController.window?.hidden = true
        UIAlertController.window = nil
        
        super.viewDidDisappear(animated)
    }
    
    class func makeOverlayPopup(title: String, _ msg: String, _ style: UIAlertControllerStyle = .Alert) -> UIAlertController {
        return UIAlertController(title: title, message: msg, preferredStyle: style)
    }
    
    func overlay() {
        Util.runOnMainThread{
            UIAlertController.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            UIAlertController.window?.rootViewController = UIViewController()
            UIAlertController.window?.windowLevel = UIWindowLevelAlert + 1
            UIAlertController.window?.makeKeyAndVisible()
            UIAlertController.window?.rootViewController!.presentViewController(self, animated: true) { () -> Void in }
        }
    }
    
    func addButton(text: String, style: UIAlertActionStyle, action: ()->()) {
        self.addAction(UIAlertAction(title: text, style: style) { _ in action() } )
    }
    
}





