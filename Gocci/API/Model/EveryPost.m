//
//  EveryPost.m
//  Gocci
//
//  Created by デザミ on 2015/06/12.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "EveryPost.h"

@implementation EveryPost

+ (instancetype)everyPostWithJsonDictionary:(NSDictionary *)dictionary
{
	EveryPost *obj = [EveryPost new];
	
	obj.post_id = dictionary[@"post_id"];
	obj.post_user_id = dictionary[@"post_user_id"];
	obj.username = dictionary[@"username"];
	obj.profile_img = dictionary[@"profile_img"];
	obj.rest_id = dictionary[@"rest_id"];
	obj.restname = dictionary[@"restname"];
	obj.movie = dictionary[@"movie"];
	obj.thumbnail = dictionary[@"thumbnail"];
	obj.tag = dictionary[@"tag"];
	obj.value = dictionary[@"value"];
	obj.memo = dictionary[@"memo"];
	obj.post_date = dictionary[@"post_date"];
	obj.cheer_flag = dictionary[@"cheer_flag"];
	obj.like_num = [dictionary[@"gochi_num"] integerValue];
	obj.comment_num = [dictionary[@"comment_num"] integerValue];
	obj.follow_flag = [dictionary[@"follow_flag"] integerValue];
	obj.want_flag = dictionary[@"want_flag"] ;
    obj.pushed_at = dictionary[@"gochi_flag"];
    obj.flag  = [dictionary[@"gochi_flag"] integerValue];
    obj.tel = dictionary[@"tell"];
    obj.homepage = dictionary[@"homepage"];
    obj.total_cheer_num = dictionary[@"total_cheer_num"];
    obj.lat = dictionary[@"X(lon_lat)"];
    obj.lon = dictionary[@"Y(lon_lat)"];
    obj.locality = dictionary[@"locality"];
    obj.tag_category = dictionary[@"category"];
    obj.atmosphere = dictionary[@"atmosphere"];

	return obj;
}

@end
