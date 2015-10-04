//
//  Restaurant.m
//  Gocci
//

#import "Restaurant.h"

@implementation Restaurant

+ (instancetype)restaurantWithDictionary:(NSDictionary *)dictionary
{
    Restaurant *obj = [Restaurant new];
    
    obj.category = dictionary[@"category"];
    obj.distance = [dictionary[@"distance"] floatValue];
    obj.lat = [dictionary[@"lat"] floatValue];
    obj.lon = [dictionary[@"lon"] floatValue];
    obj.locality = dictionary[@"locality"];
    obj.restname = dictionary[@"restname"];
    obj.tel = dictionary[@"tell"];
    obj.homepage = dictionary[@"homepage"];
    obj.total_cheer_num = dictionary[@"total_cheer_num"];
    obj.want_tag = dictionary[@"want_flag"];
    obj.rest_id = dictionary[@"rest_id"];
    
    return obj;
}

@end
