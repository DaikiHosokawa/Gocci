//
//  TimelinePost.h
//  Gocci
//

#import <Foundation/Foundation.h>

/**
 *  API: /timeline/ から取得される結果の各データ
 */
@interface TimelinePost_v4 : NSObject

@property BOOL cheer_flag;
@property BOOL  gochi_flag;
@property (nonatomic,copy) NSString *hls_movie;
@property (nonatomic,copy) NSString *movie;
@property (nonatomic,copy) NSString *post_date;
@property (nonatomic,copy) NSString *post_id ;
@property (nonatomic,copy) NSString *rest_id ;
@property (nonatomic,copy) NSString *restname;
@property (nonatomic,copy) NSString *thumbnail;
@property (nonatomic,copy) NSString *user_id;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *value;
@property (nonatomic,copy) NSString *profile_img;
+ (instancetype)timelinePostWithDictionary:(NSDictionary *)dictionary;

@end
