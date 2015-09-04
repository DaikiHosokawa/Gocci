//
//  const.h
//  Gocci
//
//  Created by Sem on 9/4/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#ifndef Gocci_const_h
#define Gocci_const_h

// TODO change this in the release version
#define INDEVEL 1

#ifdef INDEVEL
#define SPLASH_TIME 0.5
#else
#define SPLASH_TIME 10.0    // TODO Discuss: too long in my opinion
#endif

#ifdef INDEVEL
#define API_BASE_URL (@"https://api.gocci.me/v1/mobile/")
#else
#define API_BASE_URL (@"http://test.api.gocci.me/v1/mobile/")
#endif

#define FACEBOOK_APP_ID (@"673123156062598")

#ifdef INDEVEL
#define COGNITO_POOL_ID (@"us-east-1:b563cebf-1de2-4931-9f08-da7b4725ae35")
#define COGNITO_POOL_REGION (AWSRegionUSEast1)
#else
#define COGNITO_POOL_ID (@"us-east-1:b0252276-27e1-4069-be84-3383d4b3f897")
#define COGNITO_POOL_REGION (AWSRegionUSEast1)
#endif

//


#endif // Gocci_const_h END
