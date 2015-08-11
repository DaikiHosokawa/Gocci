//
//  TimelinePost.h
//  Gocci
//

#import <Foundation/Foundation.h>

/**
 *  API: /timeline/ から取得される結果の各データ
 */
@interface Notice : NSObject

@property (nonatomic) NSString *noticeMessage;
@property (nonatomic) NSString *notice_date;
@property (nonatomic) NSString *picture;
@property (nonatomic) NSString *username;

+ (instancetype)noticeWithDictionary:(NSDictionary *)dictionary;

@end
