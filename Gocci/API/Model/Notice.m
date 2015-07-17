//
//  TimelinePost.m
//  Gocci
//

#import "Notice.h"

@implementation Notice

+ (instancetype)noticeWithDictionary:(NSDictionary *)dictionary
{
    Notice *obj = [Notice new];
    
    obj.notice = dictionary[@"notice"];
    obj.noticed = dictionary[@"notice_date"];
    obj.picture = dictionary[@"profile_img"];
    
    return obj;
}

@end
