//
//  APIClient.h
//  Gocci
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  API 通信クラス
 */
@interface APIClient : NSObject

+ (id)getManager ;

/**
 *  timeline
 
 *  @param handler
 */
+ (void)Timeline:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  distance
 
 *  @param handler
 */
+ (void)Distance:(double)latitude
       longitude:(double)longitude call:(NSString *)call category_id:(NSString *)category_id value_id:(NSString *)value_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  recommend
 
 *  @param handler
 */
+ (void)Reco:(NSString *)call category_id:(NSString *)category_id value_id:(NSString *)value_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  Follow
 
 *  @param handler
 */
+ (void)Follow:(NSString *)call category_id:(NSString *)category_id value_id:(NSString *)value_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  popular
 *
 *  @param handler
 */
+ (void)Popular:(void (^)(id result, NSUInteger code, NSError *error))handler;


/**
 *  restaurant
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)Restaurant:(NSString *)rest_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  profile
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)User:(NSString *)target_user_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  lifelog/
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)LifelogWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler;
+ (void)LifelogWithDate:(NSString *)date handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


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
                  latitude:(CLLocationDegrees)latitude
                 longitude:(CLLocationDegrees)longitude
                     limit:(NSUInteger)limit
                   handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


/*
 *  dist/
 *
 *  @param latitude
 *  @param longitude
 *  @param limit
 *  @param handler
 *  @param cacheHandler キャッシュされた結果を取得
 */
+ (void)Near:(double)latitude
   longitude:(double)longitude handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  movie/
 *
 *  @param fileURL
 *  @param handler
 */
+ (void)POST:(NSString *)movie_name rest_id:(NSString*)rest_id cheer_flag:(NSString *)cheer_flag value:(NSString *)value category_id:(NSString*)category_id tag_id:(NSString*)tag_id memo:(NSString *)memo handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

///**
// *  ファイルのダウンロード
// *  既にダウンロード済みのファイルを指定した場合は再度ダウンロードせず、そのファイルのローカルパスを返す
// *  ファイルはキャッシュディレクトリに保存される
// *
// *  @param movieURL ファイルのURL
// *  @param handler  完了イベントハンドラ
// */
//+ (void)downloadMovieFile:(NSString *)movieURL completion:(void (^)(NSURL *fileURL, NSError *error))handler;


/**
 *
 *  notice
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)Notice:(void (^)(id result, NSUInteger code, NSError *error))handler;


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

/**
 *  violation
 *
 *  @param post_id
 *  @param handler
 */
+ (void)postBlock:(NSString *)post_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


/**
 *  comment
 *
 *  @param post_id
 *  @param handler
 */
+ (void)postComment:(NSString *)text
            post_id:(NSString *)post_id
            handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  login
 *
 *  @param post_id
 *  @param handler
 */
+ (void)Login:(NSString *)identity_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

+ (void)loginWithSNS:(NSString *)identity_id os:(NSString *)os model:(NSString *)model register_id:(NSString *)register_id handler:(void (^)(id, NSUInteger, NSError *))handler;

/**
 *  comment
 *
 *  @param post_id
 *
 */
+ (void)commentJSON:(NSString *)post_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


/**
 *  profile
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)CheerList:(NSString *)target_user_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  Regist new user
 *
 *
 *
 *  @param username username
 *  @param pwd  password
 *  @param email email
 */
+ (void)Signup:(NSString *)username
            os:(NSString *)os
         model:(NSString *)model
   register_id:(NSString *)register_id
       handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  postFeedback
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)postFeedback:(NSString *)feedback handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


/**
 *  Conversion
 *
 *
 *
 *  @param username username
 *  @param pwd  password
 *  @param email email
 */
+ (void)Conversion:(NSString *)username
       profile_img:(NSString *)profile_img
                os:(NSString *)os
             model:(NSString *)model
       register_id:(NSString *)register_id
           handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  want
 *
 *  @param rest_id
 *  @param handler
 */
+ (void)postWant:(NSString *)rest_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  Unwant
 *
 *  @param rest_id
 *  @param handler
 */
+ (void)postUnWant:(NSString *)rest_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  updateProfile
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)updateProfileBoth:(NSString *)username profile_img:(NSString *)profile_img handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  updateProfile
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)updateProfileOnlyUsername:(NSString *)username  handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


+ (void)connectWithSNS:(NSString *)provider
                 token:(NSString *)token
     profilePictureURL:(NSString *)ppurl
               handler:(void (^)(id, NSUInteger, NSError *))handler;

+ (void)disconnectWithSNS:(NSString *)provider
                 token:(NSString *)token
                  handler:(void (^)(id, NSUInteger, NSError *))handler;

+ (void)loginWithUsername:(NSString *)username password:(NSString*)pass os:(NSString *)os model:(NSString *)model register_id:(NSString *)register_id handler:(void (^)(id, NSUInteger, NSError *))handler;

+ (void)setPassword:(NSString *)pass handler:(void (^)(id, NSUInteger, NSError *))handler;



/////////////////////////////////V4/////////////////////////////////////////

/**
 *  set/follow
 *
 *  @param target_user_id
 *  @param handler
 */
+ (void)postFollow:(NSString *)target_user_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  unset/follow
 *
 *  @param target_user_id
 *  @param handler
 */
+ (void)postUnFollow:(NSString *)target_user_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  set/gochi
 *
 *  @param post_id
 *  @param handler
 */
+ (void)set_gochi:(NSString *)post_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  unset/gochi
 *
 *  @param post_id
 *  @param handler
 */
+ (void)unset_gochi:(NSString *)post_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  get/gochiline
 *
 *  @param post_id
 *  @param handler
 */
+ (void)Gochi:(NSString *)page category_id:(NSString *)category_id value_id:(NSString *)value_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  get/follow
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)Follow:(NSString *)user_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;

/**
 *  get/follower
 *
 *  @param handler 完了イベントハンドラ
 */
+ (void)Follower:(NSString *)user_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler;


@end
