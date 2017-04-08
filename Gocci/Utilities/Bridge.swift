//
//  Bridge.swift
//  Gocci
//
//  Created by Ma Wa on 30.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


@objc class Bridge: NSObject {
    
    class func scheduleTwitterVideoSharingTask(tweetMessage: String, mp4VideoFilePath: String) {
        TwitterVideoSharingTask(tweetMessage: tweetMessage, relativeFilePath: mp4VideoFilePath).schedule()
    }
    
    //class func authenticateWithTwitterIfNecessary (fromViewController vc: UIViewController, and: TwitterAuthentication.Token?->()) {
    class func authenticateWithTwitterIfNecessary(vc: UIViewController, and: Bool->()) {
        TwitterAuthentication.authenticate(currentViewController: vc, and: { and( $0 != nil ) } )
    }
    
    class func authenticateWithFacebookWithPublishRIghtsIfNecessary(vc: UIViewController, and: Bool->()) {
        FacebookAuthentication.authenticateWithPublishRights(currentViewController: vc, and: { and( $0 != nil ) } )
    }
    
    class func videoTweetMessageRemainingCharacters(tweet: String) -> Int {
        return TwitterSharing.videoTweetMessageRemainingCharacters(tweet)
    }
    
}