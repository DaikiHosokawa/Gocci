//
//  Const.swift
//  Gocci
//
//  Created by Ma Wa on 17.02.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation



#if TEST_BUILD

#elseif LIVE_BUILD

#endif


// All file & directory paths relative to root
let POSTED_VIDEOS_DIRECTORY = "Documents/PostedVideos"

let INASE_PRIVACY_URL = "http://inase-inc.jp/rules/privacy/"
let INASE_RULES_URL = "http://inase-inc.jp/rules/"
let GOCCI_APP_STORE_URL = "itms://itunes.apple.com/jp/app/id968630887"


/// AWS and Cognito
#if TEST_BUILD
    let COGNITO_POOL_ID = "us-east-1:b563cebf-1de2-4931-9f08-da7b4725ae35"
    let COGNITO_POOL_REGION = AWSRegionType.USEast1
    let AWS_S3_VIDEO_UPLOAD_BUCKET = "gocci.movies.bucket.jp-test"
    let AWS_S3_PROFILE_IMAGE_UPLOAD_BUCKET = "gocci.imgs.provider.jp-test"
    let GOCCI_DEV_AUTH_PROVIDER_STRING = "test.login.gocci"
#elseif LIVE_BUILD
    let COGNITO_POOL_ID = "us-east-1:b0252276-27e1-4069-be84-3383d4b3f897"
    let COGNITO_POOL_REGION = AWSRegionType.USEast1
    let AWS_S3_VIDEO_UPLOAD_BUCKET = "gocci.movies.bucket.jp"
    let AWS_S3_PROFILE_IMAGE_UPLOAD_BUCKET = "gocci.imgs.provider.jp"
    let GOCCI_DEV_AUTH_PROVIDER_STRING = "login.gocci"
#endif


/// SNS etc.

#if TEST_BUILD
    let FACEBOOK_APP_ID = "977612005613710"
#elseif LIVE_BUILD
    let FACEBOOK_APP_ID = "673123156062598"
#endif

let FACEBOOK_PROVIDER_STRING = "graph.facebook.com"
let FACEBOOK_STORY_ACTION_ID = "gocci:record"

let TWITTER_CONSUMER_KEY = "kurJalaArRFtwhnZCoMxB2kKU"
let TWITTER_CONSUMER_SECRET = "oOCDmf29DyJyfxOPAaj8tSASzSPAHNepvbxcfVLkA9dJw7inYa"
let TWITTER_PROVIDER_STRING = "api.twitter.com"

let PROFILE_IMAGE_UPLOAD_RESOLUTION = 120 // pixel width and height


//
//#if TEST_BUILD
//    let GOCCI_TWITTER_TAG = "#Gokky"
//#elseif LIVE_BUILD
//    let GOCCI_TWITTER_TAG = "#Gocci"
//#endif




