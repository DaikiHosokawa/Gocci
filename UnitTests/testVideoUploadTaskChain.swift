//
//  testVideoUploadTaskChain.swift
//  Gocci
//
//  Created by Ma Wa on 09.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import XCTest

class testVideoUploadTaskChain: XCTestCase {
    
    override class func setUp() {
        
//        username:    VideoUploadUnitTest
//        user id:     921
//        identity_id: us-east-1:6f396fe0-9b3f-4d80-af41-fa1a22763b2b
        
        Persistent.setupAndCacheAllDataFromDisk()
        
        Network.startNetworkStatusMonitoring()
        
        TaskScheduler.startScheduler()
        
        let iid = "us-east-1:6f396fe0-9b3f-4d80-af41-fa1a22763b2b"
        
        NetOp.loginWithIID(iid) { code, msg in
            switch code {
            case NetOpResult.NETOP_SUCCESS:
                AWS2.connectToBackEndWithUserDefData().continueWithBlock{ task -> AnyObject! in
                    print("Login at gocci server as: ", Persistent.user_name!)
                    return nil
                }
            default:
                fatalError()
            }
        }
        
        super.setUp()
    }
    
    
    
    class TestGocciVideoSharingTask: GocciVideoSharingTask {
        
        var expectation: XCTestExpectation?
        
        override func run(finished: State->()) {
            print("*** State change to: \(state) : \(String(self.dynamicType)).")
            
            let proxy: State->() = { state in
                
                if state == .DONE {
                    self.expectation?.fulfill()
                }
                finished(state)
            }
            
            super.run(proxy)
        }
    }
    
    func testUploadOfChainTasksBlackVideo() {
        
        let timestamp = Util.timestamp()
        let userID = "921"
        let restaurantID = "1"
        let categoryID = "2"
        let comment = "delicious darkness"
        let videoFilePath = NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!
        
        let task = TestGocciVideoSharingTask(timestamp: timestamp, userID: userID, restaurantID: restaurantID, cheerFlag: true, kakaku: "1200", categoryID: categoryID, comment: comment, videoFilePath: videoFilePath)
        
        task.expectation = expectationWithDescription("bla")
        task.schedule()
        
        waitForExpectationsWithTimeout(5.0, handler: nil)

    }
    
    
}
