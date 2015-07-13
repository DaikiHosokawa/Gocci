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
    obj.goodNum = [dictionary[@"gochi_num"] integerValue];
    obj.locality = dictionary[@"locality"];
    obj.movie = dictionary[@"movie"];
    obj.picture = dictionary[@"profile_img"];
    obj.rest_id = dictionary[@"rest_id"];
    obj.postID = dictionary[@"post_id"];
    obj.restname = dictionary[@"restname"];
    obj.starEvaluation = [dictionary[@"star_evaluation"] integerValue];
    obj.thumbnail = dictionary[@"thumbnail"];
    obj.userID = dictionary[@"user_id"];
    obj.userName = dictionary[@"username"];
    obj.timelabel = dictionary[@"post_date"];
    obj.locality = dictionary[@"locality"];
    obj.restname = dictionary[@"restname"];
    obj.tel = dictionary[@"tell"];
    obj.homepage = dictionary[@"homepage"];
    obj.category = dictionary[@"category"];
    obj.pushed_at = dictionary[@"gochi_flag"];
    obj.flag  = [dictionary[@"follow_flag"] integerValue];
    obj.tagA = dictionary[@"tag_category"];
    obj.tagB = dictionary[@"tag"];
    obj.tagC = dictionary[@"value"];
    obj.cheernum  = [dictionary[@"cheer_num"] integerValue];
    obj.lat = dictionary[@"lat"];
    obj.lon = dictionary[@"lon"];
    obj.comment = dictionary[@"memo"];
    obj.totalCheer = dictionary[@"total_cheer_num"];
    obj.want_flag = dictionary[@"want_flag"];
    return obj;
}

@end
