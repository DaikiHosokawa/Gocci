//
//  LocationClient.h
//  Gocci
//

#import <Foundation/Foundation.h>

@import CoreLocation;

extern NSString * const LocationClientErrorDomain;

typedef NS_ENUM(NSUInteger, LocationClientErrorCode) {
    LocationClientErrorCodeSettingErrorCode = 1,
    LocationClientErrorCodeInterrupted = 2,
};

typedef void (^LocationClientUpdatedBlock)(CLLocation *location, NSError *error);

/**
 *  位置情報の取得・管理
 */
@interface LocationClient : NSObject

/**
 *  キャッシュされた位置情報
 *
 *  前回に取得成功した位置情報が格納される
 */
@property (nonatomic, readonly, strong) CLLocation *cachedLocation;

+ (instancetype)sharedClient;

/**
 *  現在位置の位置情報を取得
 *
 *  @param completion 位置情報取得成功時の処理
 */
- (void)requestLocationWithCompletion:(LocationClientUpdatedBlock)completion;

@end
