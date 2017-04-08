//
//  TimelinePost.m
//  Gocci
//

#import "Follow.h"

@implementation Follow

+ (instancetype)timelinePostWithDictionary:(NSDictionary *)dictionary
{
    Follow *obj = [Follow new];
    obj.follow_flag  = [dictionary[@"follow_flag"] boolValue];
    obj.gochi_num = dictionary[@"gochi_num"];
    obj.profile_img = dictionary[@"profile_img"];
    obj.user_id = dictionary[@"user_id"];
    obj.username = dictionary[@"username"];
    return obj;
}

@end
