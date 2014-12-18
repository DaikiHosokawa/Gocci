//
//  RestaurantPost.m
//  Gocci
//
//  Created by Jack O' Lantern on 2014/12/05.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "RestaurantPost.h"
#import <ISRemoveNull/NSDictionary+RemoveNull.h>

@implementation RestaurantPost

+ (instancetype)restaurantPostWithDictionary:(NSDictionary *)dictionary
{
 //   dictionary = [dictionary dictionaryByRemovingNull];
    
    RestaurantPost *obj = [RestaurantPost new];
    obj.commentNum = [dictionary[@"comment_num"] integerValue];
    obj.goodNum = [dictionary[@"goodnum"] integerValue];
    obj.badNum =  [dictionary[@"badnum"] integerValue];
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
