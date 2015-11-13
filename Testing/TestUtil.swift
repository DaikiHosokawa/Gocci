//
//  TestUtil.swift
//  Gocci
//
//  Created by Ma Wa on 13.11.15.
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
    
    func testIfRandomUsernameMeetsExpections() {
        let ru = Util.randomUsername()

        XCTAssert(ru.length > 0, "empty string not a valid username")
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
