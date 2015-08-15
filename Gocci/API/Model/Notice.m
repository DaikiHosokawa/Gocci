//
//  TimelinePost.m
//  Gocci
//

#import "Notice.h"

@implementation Notice

+ (instancetype)noticeWithDictionary:(NSDictionary *)dictionary
{
    Notice *obj = [Notice new];
    
    obj.noticeMessage = dictionary[@"notice"];
    obj.notice_date = dictionary[@"notice_date"];
    obj.picture = dictionary[@"profile_img"];
    obj.username = dictionary[@"username"];
    
    return obj;
}

@end
