//
//  TimelinePost.m
//  Gocci
//

#import "TimelinePost.h"
#import <ISRemoveNull/NSDictionary+RemoveNull.h>

@implementation TimelinePost

+ (instancetype)timelinePostWithDictionary:(NSDictionary *)dictionary
{
 //   dictionary = [dictionary dictionaryByRemovingNull];
    
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
    
    return obj;
}

@end
