//
//  TimelinePost.m
//  Gocci
//

#import "TimelinePost_v4.h"

@implementation TimelinePost_v4

+ (instancetype)timelinePostWithDictionary:(NSDictionary *)dictionary
{
    TimelinePost_v4 *obj = [TimelinePost_v4 new];
    obj.cheer_flag  = [dictionary[@"cheer_flag"] boolValue];
    obj.gochi_flag  = [dictionary[@"gochi_flag"] boolValue];
    obj.hls_movie = dictionary[@"hls_movie"];
    obj.movie = dictionary[@"movie"];
    obj.post_date = dictionary[@"post_date"];
    obj.post_id = dictionary[@"post_id"];
    obj.rest_id = dictionary[@"rest_id"];
    obj.restname = dictionary[@"restname"];
    obj.thumbnail = dictionary[@"thumbnail"];
    obj.user_id = dictionary[@"user_id"];
    obj.username = dictionary[@"username"];
    obj.value = dictionary[@"value"];
    obj.profile_img = dictionary[@"profile_img"];    
    return obj;
}

@end
