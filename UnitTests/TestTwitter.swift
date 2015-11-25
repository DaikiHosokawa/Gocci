//
//  TestTwitter.swift
//  Gocci
//
//  Created by Markus Wanke on 18.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import XCTest

class TestTwitter: XCTestCase {
    
    
    func testIfReadyToPost() {
        TwitterAuthentication.authenticadedAndReadyToUse {
            XCTAssert($0, "not logged in. use the debug screen to login to twitter or so")
        }
    }
    
    func testIfYouCanTweetAMessage() {
        let sharer = TwitterSharing()
        sharer.onSuccess = { XCTAssert( Int($0) != nil, "No post id") }
        sharer.onFailure = { XCTAssert( false, String($0)) }
        
        let msg = Util.randomAlphaNumericStringWithLength(32)
        sharer.tweetMessage(msg)
    }
    
    func testIfYouCanPosyMaxLengthOfAJapaneseMessage() {
        let sharer = TwitterSharing()
        sharer.onSuccess = { XCTAssert( Int($0) != nil, "No post id") }
        sharer.onFailure = { XCTAssert( false, String($0)) }
        
        let msg = Util.randomKanjiStringWithLength(140)
        sharer.tweetMessage(msg)
    }
    
    func testIfTooLongTweetsAreCatched() {
        let sharer = TwitterSharing()
        sharer.onSuccess = { _ in XCTAssert( false, "wtf should nerver work") }
        sharer.onFailure = { err in
            switch (err) {
            case TwitterSharing.TwitterSharingError.ERROR_TWEET_MESSAGE_OVER_140:
                break
            default:
                XCTAssert(false, "140 over char error not catched, instead: \(err)")
            }
        }
        
        let msg = Util.randomKanjiStringWithLength(141)
        sharer.tweetMessage(msg)
    }
    
    func testIfWeCanPostAVideo() {
        let videoURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!)
        
        let sharer = TwitterSharing()
        sharer.onSuccess = { XCTAssert( Int($0) != nil, "No post id"); print("============= \($0)") }
        sharer.onFailure = { XCTFail( String($0) )}
        let msg = Util.randomKanjiStringWithLength(100)
        sharer.tweetVideo(localVideoFileURL: videoURL, message: msg)
    }
    
}
