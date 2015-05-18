//
//  Restaurant.h
//  Gocci
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

@property (nonatomic, copy) NSString *category;
@property (nonatomic) CGFloat distance;
@property (nonatomic) CGFloat lat;
@property (nonatomic) CGFloat lon;
@property (nonatomic, copy) NSString *locality;
@property (nonatomic, copy) NSString *restname;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *homepage;
@property (nonatomic, copy) NSString *total_cheer_num;

+ (instancetype)restaurantWithDictionary:(NSDictionary *)dictionary;

@end
