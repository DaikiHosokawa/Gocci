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
    }
    
    var uid: String! = nil
    var username: String! = nil
    
    
    func test01_CreateAccountAndLogin() {
        
        let req = API4.auth.signup()
        
        req.parameters.username = "TEST_\(Util.timestamp1970())"
        username = req.parameters.username
        
        req.onAnyAPIError { XCTAssert(false) }
        
        req.perform { payload in
            print("USERNAME: \(req.parameters.username)")
            print("IID: \(payload.identity_id)")
            
            let req = API4.auth.login()
            
            req.parameters.identity_id = payload.identity_id
            
            req.onAnyAPIError { XCTAssert(false) }
            
            req.perform { payload in
                self.uid = payload.user_id
                XCTAssertEqual(payload.badge_num, 0)
                XCTAssertEqual(payload.username, self.username)
                
                XCTAssert(true)
            }
            
            XCTAssert(true)
        }
    }
    
    func test02_HeatMapData() {
        
        let req = API4.get.heatmap()
        
        req.onAnyAPIError { XCTAssert(false) }
        
        req.perform { payload in XCTAssert(payload.rests.count > 5) }
        
    }
    
}















