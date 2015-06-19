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
 *  timeline_date/
 *
 *  @param latitude
 *  @param longitude
 *  @param limit
 *  @param handler   
 */
+ (void)distTimelineWithLatitude:(double)latitude longitude:(double)longitude limit:(NSUInteger)limit handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


/**
 *  timeline/
 *
 *  @param latitude
 *  @param longitude
 *  @param limit
 *  @param handler
 */
+ (void)distTimelineWithLatitudeAll:(NSUInteger)limit handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

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
 *  lifelog/
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
 *  dist/
 *
 *  @param latitude
 *  @param longitude
 *  @param limit
 *  @param handler
 *  @param cacheHandler キャッシュされた結果を取得
 */
+ (void)distWithLatitude:(CGFloat)latitude
               longitude:(CGFloat)longitude
                   limit:(NSUInteger)limit
                 handler:(void (^)(id result, NSUInteger code, NSError *error))handler
                useCache:(void (^)(id cachedResult))cacheHandler;

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
+ (void)movieWithFilePathURL:(NSURL *)fileURL restname:(NSString*)restaurantName star_evaluation:(NSInteger )cheertag value:(NSInteger )value category:(NSString*)category atmosphere:(NSString*)atmosphere comment:(NSString *)comment handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  ファイルのダウンロード
 *  既にダウンロード済みのファイルを指定した場合は再度ダウンロードせず、そのファイルのローカルパスを返す
 *  ファイルはキャッシュディレクトリに保存される
 *
 *  @param movieURL ファイルのURL
 *  @param handler  完了イベントハンドラ
 */
+ (void)downloadMovieFile:(NSString *)movieURL completion:(void (^)(NSURL *fileURL, NSError *error))handler;

/**
 *  Regist new user
 *
 *
 *
 *  @param username username
 *  @param pwd  password
 *  @param email email
 */
+ (void)registUserWithUsername:(NSString *)username
                  withPassword:(NSString *)pwd
                     withEmail:(NSString *)email
                  withToken_id:(NSString *)token_id
                       handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  Login user
 *
 *
 *
 *  @param username username
 *  @param pwd  password
 */
+ (void)loginUserWithUsername:(NSString *)username
                 withPassword:(NSString *)pwd
                 WithToken_id:(NSString *)token_id
                      handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


/**
 *
 *  notice
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)notice_WithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler;


/**
 *  goodinsert
 *
 *  @param post_id
 *  @param handler
 */
+ (void)postGood:(NSString *)post_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  delete
 *
 *  @param post_id
 *  @param handler
 */
+ (void)postDelete:(NSString *)post_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;
@end
