//
//  const.h
//  Gocci
//
//  Created by Markus Wanke on 9/4/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#ifndef GOCCI_CONST_H
#define GOCCI_CONST_H


/// #######################################################################################
// The app will start with a debug screen to test logins etc.
#define START_WITH_DEBUG_SCREEN

/// #######################################################################################
// Userdata will be deleted everytime the app starts
//#define FRESH_START

/// #######################################################################################
// Video recording is skipped and a default video is choosen to safe time and use the simulator
//#define SKIP_VIDEO_RECORDING

/// #######################################################################################
//#define ENTRY_POINT_JUMP (@"jumpSettingsTableViewController")
//#define ENTRY_POINT_JUMP (@"jumpUsersViewController")
//#define ENTRY_POINT_JUMP (@"jumpHeatMapViewController")

/// #######################################################################################


// INDEVEL is gone now, please use:
//#if TEST_BUILD
//
//#elif LIVE_BUILD
//
//#endif

// #######################################################################################
// #######################################################################################


// All file & directory paths relative to root
#define POSTED_VIDEOS_DIRECTORY (@"Documents/PostedVideos")

#define INASE_PRIVACY_URL (@"http://inase-inc.jp/rules/privacy/")
#define INASE_RULES_URL (@"http://inase-inc.jp/rules/")
#define GOCCI_APP_STORE_URL (@"itms://itunes.apple.com/jp/app/id968630887")



#if TEST_BUILD
#define RECORD_SECONDS 7
#elif LIVE_BUILD
#define RECORD_SECONDS 7
#endif


/// Gocci API 2
#if TEST_BUILD
#define API_BASE_URL (@"http://test.mobile.api.gocci.me/v1/mobile/")
#define API_BASE_URL_V4 (@"http://test.mobile.api.gocci.me/v4/")
#define API_BASE_DOMAIN (@"test.mobile.api.gocci.me")
#define GOCCI_DEV_AUTH_PROVIDER_STRING (@"test.login.gocci")
#elif LIVE_BUILD
#define API_BASE_URL (@"https://mobile.api.gocci.me/v1/mobile/")
#define API_BASE_URL_V4 (@"https://mobile.api.gocci.me/v4")
#define API_BASE_DOMAIN (@"mobile.api.gocci.me")
#define GOCCI_DEV_AUTH_PROVIDER_STRING (@"login.gocci")
#endif

/// AWS and Cognito
#if TEST_BUILD
#define COGNITO_POOL_ID (@"us-east-1:b563cebf-1de2-4931-9f08-da7b4725ae35")
#define COGNITO_POOL_REGION (AWSRegionUSEast1)
#define COGNITO_POOL_REGION_SWIFT AWSRegionType.USEast1
#define AWS_S3_VIDEO_UPLOAD_BUCKET (@"gocci.movies.bucket.jp-test")
#elif LIVE_BUILD
#define COGNITO_POOL_ID (@"us-east-1:b0252276-27e1-4069-be84-3383d4b3f897")
#define COGNITO_POOL_REGION (AWSRegionUSEast1)
#define COGNITO_POOL_REGION_SWIFT AWSRegionType.USEast1
#define AWS_S3_VIDEO_UPLOAD_BUCKET (@"gocci.movies.bucket.jp")
#endif


#if TEST_BUILD
#define FACEBOOK_APP_ID (@"977612005613710")
#elif LIVE_BUILD
#define FACEBOOK_APP_ID (@"673123156062598")
#endif

#define FACEBOOK_PROVIDER_STRING (@"graph.facebook.com")
#define FACEBOOK_STORY_ACTION_ID (@"gocci:record")

#define TWITTER_CONSUMER_KEY (@"kurJalaArRFtwhnZCoMxB2kKU")
#define TWITTER_CONSUMER_SECRET (@"oOCDmf29DyJyfxOPAaj8tSASzSPAHNepvbxcfVLkA9dJw7inYa")
#define TWITTER_PROVIDER_STRING (@"api.twitter.com")

#define GOOGLE_MAP_SERVICE_API_KEY (@"AIzaSyDfZOlLwFm0Wv13lNgJF9nsfXlAmUTzHko")


#if TEST_BUILD
#define GOCCI_TWITTER_TAG (@"#Gokky")
#elif LIVE_BUILD
#define GOCCI_TWITTER_TAG (@"#Gocci")
#endif




// /////////////////////////////////////////////////////////////////////////////////////////////////////
// Some protection for wrong scheme & compile configurations
#ifndef TEST_BUILD
#error "Please define TEST_BUILD and LIVE_BUILD as 1 and 0 and so that (LIVE_BUILD != LIVE_BUILD) == true"
#endif

#ifndef LIVE_BUILD
#error "Please define TEST_BUILD and LIVE_BUILD as 1 and 0 and so that (LIVE_BUILD != LIVE_BUILD) == true"
#endif

#if LIVE_BUILD == TEST_BUILD
#error "Please define TEST_BUILD and LIVE_BUILD as 1 and 0 and so that (LIVE_BUILD != LIVE_BUILD) == true"
#endif

#endif // GOCCI_CONST_H END
