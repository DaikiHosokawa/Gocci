//
//  Logging.swift
//  Gocci
//
//  Created by Ma Wa on 11.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



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
    
    static func printInColor<T>(r: Int, _ g: Int, _ b: Int, _ object: T) {
        print("\(ESCAPE)fg\(r),\(g),\(b);\(object)   \(RESET)")
    }
    
    static func error<T>(object: T) {
        print("\(ESCAPE)fg255,0,0;ERROR: \(object)   \(RESET)")
    }
}
