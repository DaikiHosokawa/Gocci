//
//  TimelinePost.h
//  Gocci
//

#import <Foundation/Foundation.h>

/**
 *  API: /timeline/ から取得される結果の各データ
 */
@interface Follow : NSObject

@property BOOL follow_flag ;
@property (nonatomic,copy) NSString *gochi_num;
@property (nonatomic,copy) NSString *profile_img;
@property (nonatomic,copy) NSString *user_id;
@property (nonatomic,copy) NSString *username ;


+ (instancetype)timelinePostWithDictionary:(NSDictionary *)dictionary;

@end
