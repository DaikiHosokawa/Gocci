//
//  TestUtil.swift
//  Gocci
//
//  Created by Markus Wanke on 18.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import XCTest

class TestUtil: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIfRandomUsernameHasCorrectFormat() {
        let rus = Util.randomUsername()
        XCTAssert(rus.length > 0, "username is empty string")
        XCTAssert(rus.length < 20, "username is too long")
    }
    
    func testIfRandomRegisterHasTheRightLengthOf64() {
        XCTAssertEqual(Util.generateFakeDeviceID().length, 64)
    }
    
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
