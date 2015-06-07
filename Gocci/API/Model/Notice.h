//
//  TimelinePost.h
//  Gocci
//

#import <Foundation/Foundation.h>

/**
 *  API: /timeline/ から取得される結果の各データ
 */
@interface Notice : NSObject

@property (nonatomic) NSString *notice;
@property (nonatomic) NSString *noticed;
@property (nonatomic) NSString *picture;

+ (instancetype)noticeWithDictionary:(NSDictionary *)dictionary;

@end
