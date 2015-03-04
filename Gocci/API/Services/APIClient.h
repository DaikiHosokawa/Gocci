//
//  APIClient.h
//  Gocci
//

#import <Foundation/Foundation.h>

/**
 *  API 通信クラス
 */
@interface APIClient : NSObject

/**
 *  timeline/
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)timelineWithLimit:(NSString *)limit handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
*  restaurant/
*
*  @param handler 完了イベントハンドラ
*/
+ (void)restaurantWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler;
+ (void)restaurantWithRestName:(NSString *)restName handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  profile/
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)profileWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler;
+ (void)profileWithUserName:(NSString *)userName handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  profile/
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)LifelogWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler;
+ (void)LifelogWithDate:(NSString *)date handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


/**
 *
 *  profile_other
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)profile_otherWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler;
+ (void)profile_otherWithUserName:(NSString *)userName handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  search/
 *
 *  @param restName
 *  @param latitude
 *  @param longitude
 *  @param limit
 *  @param handler   
 */
+ (void)searchWithRestName:(NSString *)restName
                  latitude:(CGFloat)latitude
                 longitude:(CGFloat)longitude
                     limit:(NSUInteger)limit
                   handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  dist/
 *
 *  @param latitude
 *  @param longitude
 *  @param limit
 *  @param handler
 */
+ (void)distWithLatitude:(CGFloat)latitude
               longitude:(CGFloat)longitude
                   limit:(NSUInteger)limit
                 handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  dist/ 2
 *
 *  @param latitude
 *  @param longitude
 *  @param limit
 *  @param handler
 */
+ (void)distWithLatitude2:(CGFloat)latitude
               longitude2:(CGFloat)longitude
                   limit2:(NSUInteger)limit
                 handler2:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  post_restname/
 *
 *  @param restaurantName
 *  @param handler
 */
+ (void)postRestname:(NSString *)restaurantName handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  movie/
 *
 *  @param fileURL
 *  @param handler 
 */
+ (void)movieWithFilePathURL:(NSURL *)fileURL restname:(NSString*)restaurantName handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  ファイルのダウンロード
 *  既にダウンロード済みのファイルを指定した場合は再度ダウンロードせず、そのファイルのローカルパスを返す
 *  ファイルはキャッシュディレクトリに保存される
 *
 *  @param movieURL ファイルのURL
 *  @param handler  完了イベントハンドラ
 */
+ (void)downloadMovieFile:(NSString *)movieURL completion:(void (^)(NSURL *fileURL, NSError *error))handler;

@end
