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
	obj.username = dictionary[@"user_name"];
	obj.profile_img = dictionary[@"picture"];
	obj.post_rest_id = dictionary[@"post_rest_id"];
	obj.restname = dictionary[@"restname"];
	obj.movie = dictionary[@"movie"];
	obj.thumbnail = dictionary[@"thumbnail"];
	obj.category = dictionary[@"category"];
	obj.tag = dictionary[@"tag"];
	obj.value = dictionary[@"value"];
	obj.memo = dictionary[@"comment"];
	obj.post_date = dictionary[@"post_date"];
	obj.cheer_flag = dictionary[@"cheer_flag"];
	obj.like_num = [dictionary[@"like_num"] integerValue];
	obj.comment_num = [dictionary[@"comment_num"] integerValue];
	obj.follow_flag = [dictionary[@"follow_flag"] integerValue];
	obj.like_flag = [dictionary[@"like_flag"] integerValue];
	obj.want_flag = [dictionary[@"want_flag"] integerValue];

	return obj;
}

@end
