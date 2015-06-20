//
//  TimelinePost.m
//  Gocci
//

#import "TimelinePost.h"

@implementation TimelinePost

+ (instancetype)timelinePostWithDictionary:(NSDictionary *)dictionary
{
    TimelinePost *obj = [TimelinePost new];
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
    obj.timelabel = dictionary[@"date_time"];
    obj.locality = dictionary[@"locality"];
    obj.restname = dictionary[@"restname"];
    obj.tel = dictionary[@"tell"];
    obj.homepage = dictionary[@"homepage"];
    obj.category = dictionary[@"category"];
    obj.pushed_at = dictionary[@"pushed_at"];
    obj.flag  = [dictionary[@"status"] integerValue];
    obj.tagA = dictionary[@"tag_category"];
    obj.tagB = dictionary[@"atmosphere"];
    obj.tagC = dictionary[@"value"];
    obj.cheernum  = [dictionary[@"cheer_num"] integerValue];
    obj.lat = dictionary[@"lat"];
    obj.lon = dictionary[@"lon"];
    obj.comment = dictionary[@"comment"];
    obj.totalCheer = dictionary[@"total_cheer_num"];
    obj.want_flag = dictionary[@"want_flag"];
    return obj;
}

@end
