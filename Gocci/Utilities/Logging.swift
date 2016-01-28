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
//#if TEST_BUILD
        if verbose {
            Lo.printInColor(logColor.r, logColor.g, logColor.b, msg)
            
            appendToFile("LOG: " + msg)
        }
//#endif
    }
    
    static func sep(head: String) {
//#if TEST_BUILD
        if verbose {
            let ich = String(self.dynamicType).replace(".type", withString: "")
            let msg = "=== \(head)  (send by '\(ich)') "
            let balken = String(count: max(118 - msg.length, 0), repeatedValue: Character("="))
            Lo.printInColor(logColor.r, logColor.g, logColor.b, String(count: 120, repeatedValue: Character("=")))
            Lo.printInColor(logColor.r, logColor.g, logColor.b, msg + "  " + balken)
            
            appendToFile("HEAD: " + head)
        }
//#endif
    }
    
    static func err(msg: String) {
//#if TEST_BUILD
        let ich = String(self.dynamicType).replace(".type", withString: "")
        let head = "=== ERROR in '\(ich)'"
        let balken = String(count: max(104 - msg.length, 0), repeatedValue: Character("="))
        Lo.error(String(count: 120, repeatedValue: Character("=")))
        Lo.error(head + "  " + balken)
        Lo.error(msg)
        
        appendToFile("ERROR: " + msg)
//#endif
    }

    func log(msg: String) {
        self.dynamicType.log(msg)
    }
    
    func sep(head: String) {
        self.dynamicType.sep(head)
    }
    
    func err(head: String) {
        self.dynamicType.err(head)
    }
    
    
    static func appendToFile(msg: String) {
        
        let logDir = NSURL.fileURLWithPath(NSFileManager.documentsDirectory())
        let logFile = logDir.URLByAppendingPathComponent("log.txt")
        
        
        let data = (msg+"\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        if NSFileManager.fileExistsAtURL(logFile) {
            
            if let fileHandle =  try? NSFileHandle(forWritingToURL: logFile) {
                
                fileHandle.seekToEndOfFile()
                fileHandle.writeData(data)
                fileHandle.closeFile()
            }
            else {
                print("Can't open fileHandle \(err)")
            }
        }
        else {
            do {
                try data.writeToURL(logFile, options: NSDataWritingOptions.AtomicWrite)
            }
            catch {
                print("Can't write to logfile")
            }
        }
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
