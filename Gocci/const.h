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
// Video recording is skipped and a default video is choosen to safe time and use the simulator
//#define SKIP_VIDEO_RECORDING



// INDEVEL is gone now, please use:
//#if TEST_BUILD
//
//#elif LIVE_BUILD
//
//#endif

// #######################################################################################
// #######################################################################################




#if TEST_BUILD
#define RECORD_SECONDS 1
#elif LIVE_BUILD
#define RECORD_SECONDS 7
#endif


/// Gocci API 2
#if TEST_BUILD
#define API_BASE_URL (@"http://test.mobile.api.gocci.me/v1/mobile/")
#define API_BASE_URL_V4 (@"http://test.mobile.api.gocci.me/v4/")
#define API_BASE_DOMAIN (@"test.mobile.api.gocci.me")
#elif LIVE_BUILD
#define API_BASE_URL (@"https://mobile.api.gocci.me/v1/mobile/")
#define API_BASE_URL_V4 (@"https://mobile.api.gocci.me/v4")
#define API_BASE_DOMAIN (@"mobile.api.gocci.me")
#endif




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
