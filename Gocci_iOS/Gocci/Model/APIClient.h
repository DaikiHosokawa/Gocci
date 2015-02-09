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
 *
 *  profile_other
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)profile_otherWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler;
+ (void)profile_otherWithUserName:(NSString *)userName handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

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
