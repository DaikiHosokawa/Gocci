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
    obj.noticed = dictionary[@"noticed"];
    obj.picture = dictionary[@"picture"];
    
    return obj;
}

@end
