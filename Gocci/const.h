//
//  const.h
//  Gocci
//
//  Created by Sem on 9/4/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#ifndef Gocci_const_h
#define Gocci_const_h

// #######################################################################################
// Lots ob DEBUG improvments. TODO change this in the release version
#define INDEVEL

// #######################################################################################
// The app will start with a debug screen to test logins etc.
//#define START_WITH_DEBUG_SCREEN

// #######################################################################################
// NSUserDefaults will not be reseted on start up
//#define FRESH_START 1





// #######################################################################################
// #######################################################################################


#ifdef INDEVEL
#define SPLASH_TIME 0.5
#else
#define SPLASH_TIME 5.0    // TODO Discuss: too long in my opinion
#endif

#ifdef INDEVEL
#define API_BASE_URL (@"http://test.api.gocci.me/v1/mobile/")
#else
#define API_BASE_URL (@"https://api.gocci.me/v1/mobile/")
#endif

#ifdef INDEVEL
#define GOCCI_DEV_AUTH_PROVIDER_STRING (@"test.login.gocci")
#else
#define GOCCI_DEV_AUTH_PROVIDER_STRING (@"login.gocci")
#endif

#ifdef INDEVEL
#define FACEBOOK_APP_ID (@"148392115499214")
#define FACEBOOK_PROVIDER_STRING (@"graph.facebook.com")
#else
#define FACEBOOK_APP_ID (@"673123156062598")
#define FACEBOOK_PROVIDER_STRING (@"graph.facebook.com")
#endif

#define TWITTER_CONSUMER_KEY (@"kurJalaArRFtwhnZCoMxB2kKU")
#define TWITTER_CONSUMER_SECRET (@"oOCDmf29DyJyfxOPAaj8tSASzSPAHNepvbxcfVLkA9dJw7inYa")
#define TWITTER_PROVIDER_STRING (@"api.twitter.com")

#ifdef INDEVEL
#define COGNITO_POOL_ID (@"us-east-1:b563cebf-1de2-4931-9f08-da7b4725ae35")
#define COGNITO_POOL_REGION (AWSRegionUSEast1)
#else
#define COGNITO_POOL_ID (@"us-east-1:b0252276-27e1-4069-be84-3383d4b3f897")
#define COGNITO_POOL_REGION (AWSRegionUSEast1)
#endif

#define CRITTERCISM_APP_ID (@"540ab4d40729df53fc000003")

#define GOOGLE_MAP_SERVICE_API_KEY (@"AIzaSyDfZOlLwFm0Wv13lNgJF9nsfXlAmUTzHko")


#endif // Gocci_const_h END
