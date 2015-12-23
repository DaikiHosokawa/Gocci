//
//  Logging.swift
//  Gocci
//
//  Created by Ma Wa on 11.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



protocol Logable {
    static func log(msg: String)
    static func sep(head: String)
    static func err(head: String)
    
    func log(msg: String)
    func sep(head: String)
    func err(head: String)
    
    static var verbose: Bool { get }
    
    static var logColor: (r: UInt8, g: UInt8, b: UInt8) { get }
}

extension Logable {
    
    
    static func log(msg: String) {
        if verbose {
            Lo.printInColor(logColor.r, logColor.g, logColor.b, msg)
        }
    }
    
    static func sep(head: String) {
        if verbose {
            let ich = String(self.dynamicType).replace(".type", withString: "")
            let msg = "=== \(head)  (send by '\(ich)') "
            let balken = String(count: max(118 - msg.length, 0), repeatedValue: Character("="))
            Lo.printInColor(logColor.r, logColor.g, logColor.b, String(count: 120, repeatedValue: Character("=")))
            Lo.printInColor(logColor.r, logColor.g, logColor.b, msg + "  " + balken)
        }
    }
    
    static func err(msg: String) {
        
        let ich = String(self.dynamicType).replace(".type", withString: "")
        let head = "=== ERROR in '\(ich)'"
        let balken = String(count: max(104 - msg.length, 0), repeatedValue: Character("="))
        Lo.error(String(count: 120, repeatedValue: Character("=")))
        Lo.error(head + "  " + balken)
        Lo.error(msg)
    }
    
    func log(msg: String) {
        self.dynamicType.log(msg)
    }
    
    func sep(head: String) {
        self.dynamicType.sep(head)
    }
    
    func err(head: String) {
        self.dynamicType.sep(head)
    }

}

struct Lo {
    static let ESCAPE = "\u{001b}["
    
    static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
    static let RESET_BG = ESCAPE + "bg;" // Clear any background color
    static let RESET = ESCAPE + ";"   // Clear any foreground or background color
    
    static func red<T>(object: T) {
        print("\(ESCAPE)fg255,0,0;\(object)   \(RESET)")
    }
    
    static func green<T>(object: T) {
        print("\(ESCAPE)fg0,255,0;\(object)   \(RESET)")
    }
    
    static func blue<T>(object: T) {
        print("\(ESCAPE)fg0,0,255;\(object)   \(RESET)")
    }
    
    static func yellow<T>(object: T) {
        print("\(ESCAPE)fg255,255,0;\(object)   \(RESET)")
    }
    
    static func purple<T>(object: T) {
        print("\(ESCAPE)fg255,0,255;\(object)   \(RESET)")
    }
    
    static func cyan<T>(object: T) {
        print("\(ESCAPE)fg0,255,255;\(object)   \(RESET)")
    }
    
    static func printInColor<T>(r: UInt8, _ g: UInt8, _ b: UInt8, _ object: T) {
        print("\(ESCAPE)fg\(r),\(g),\(b);\(object)   \(RESET)")
    }
    
    static func error<T>(object: T) {
        print("\(ESCAPE)bg255,0,0;\(ESCAPE)fg255,255,255;\(object)\(RESET)")
    }
}
