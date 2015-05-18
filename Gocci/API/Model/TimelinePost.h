//
//  TimelinePost.h
//  Gocci
//

#import <Foundation/Foundation.h>

/**
 *  API: /timeline/ から取得される結果の各データ
 */
@interface TimelinePost : NSObject

@property (nonatomic) NSUInteger commentNum;
@property (nonatomic) NSUInteger goodNum;
@property (nonatomic )  NSInteger badNum;
@property (nonatomic,copy) NSString *locality;
@property (nonatomic,copy) NSString *movie;
@property (nonatomic,copy) NSString *picture;
@property (nonatomic,copy) NSString *postID;
@property (nonatomic,copy) NSString *restname;
@property (nonatomic) NSUInteger starEvaluation;
@property (nonatomic,copy) NSString *thumbnail;
@property (nonatomic,copy) NSString *userID;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *comment;
@property (nonatomic) NSString *timelabel;
@property (nonatomic) NSString *tel;
@property (nonatomic) NSString *homepage;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *pushed_at;
@property (nonatomic) NSInteger flag;
@property (nonatomic,copy) NSString *lat;
@property (nonatomic,copy) NSString *lon;
@property (nonatomic) NSString *tagA;
@property (nonatomic) NSString *tagB;
@property (nonatomic) NSString *tagC;
@property (nonatomic) NSInteger cheernum;
@property (nonatomic) NSString* totalCheer;

+ (instancetype)timelinePostWithDictionary:(NSDictionary *)dictionary;

@end
