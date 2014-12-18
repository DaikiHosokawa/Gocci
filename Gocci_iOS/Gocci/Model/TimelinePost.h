//
//  TimelinePost.h
//  Gocci
//

#import <Foundation/Foundation.h>

/**
 *  API: /timeline/ から取得される結果の各データ
 */
@interface TimelinePost : NSObject

@property(nonatomic) NSUInteger commentNum;
@property(nonatomic) NSUInteger goodNum;
@property(nonatomic )  NSInteger badNum;
@property(nonatomic,strong) NSString *locality;
@property(nonatomic,strong) NSString *movie;
@property(nonatomic,strong) NSString *picture;
@property(nonatomic,strong) NSString *postID;
@property(nonatomic,strong) NSString *restname;
@property(nonatomic) NSUInteger starEvaluation;
@property(nonatomic,strong) NSString *thumbnail;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) NSString *userName;

+ (instancetype)timelinePostWithDictionary:(NSDictionary *)dictionary;

@end
