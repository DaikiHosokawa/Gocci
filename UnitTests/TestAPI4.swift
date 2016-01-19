//
//  TestAPI4.swift
//  Gocci
//
//  Created by Ma Wa on 19.01.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import XCTest

class TestAPI4: XCTestCase {
    
    override class func setUp() {
        Network.startNetworkStatusMonitoring()
        
        let req = API3.auth.login()
        
        req.parameters.identity_id = "us-east-1:6f396fe0-9b3f-4d80-af41-fa1a22763b2b"
        
        req.onAnyAPIError {
            print("damn")
        }
        
        req.perform { payload in
            print("Login at gocci server as: ", payload.username)
        }
        
        super.setUp()
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
