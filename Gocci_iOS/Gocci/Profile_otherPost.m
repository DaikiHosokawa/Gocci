//
//  Profile_otherPost.m
//  Gocci
//
//  Created by Jack O' Lantern on 2014/12/05.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Profile_otherPost.h"
#import <ISRemoveNull/NSDictionary+RemoveNull.h>

@implementation Profile_otherPost


+ (instancetype)profile_otherPostWithDictionary:(NSDictionary *)dictionary
{
  //  dictionary = [dictionary dictionaryByRemovingNull];
    
    Profile_otherPost *obj = [Profile_otherPost new];
    obj.commentNum = [dictionary[@"comment_num"] integerValue];
    obj.goodNum = [dictionary[@"goodnum"] integerValue];
    obj.locality = dictionary[@"locality"];
    obj.movie = dictionary[@"movie"];
    obj.picture = dictionary[@"picture"];
    obj.postID = dictionary[@"post_id"];
    obj.restname = dictionary[@"restname"];
    obj.starEvaluation = [dictionary[@"star_evaluation"] integerValue];
    obj.thumbnail = dictionary[@"thumbnail"];
    obj.userID = dictionary[@"user_id"];
    obj.userName = dictionary[@"user_name"];
    
    return obj;
}

@end
