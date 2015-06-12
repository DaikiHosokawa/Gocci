//
//  EveryPost.h
//  Gocci
//
//  Created by デザミ on 2015/06/12.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 {
 "post_id": "3024",
 "post_user_id": "2",
 "username": "Daiki Hosokawa",
 "profile_img": "https://graph.facebook.com/100005695590701/picture",
 "post_rest_id": "1055211",
 "restname": "SATSUKI （サツキ）",
 "movie": "../movies/fbe796337e4d84aa681bd1db57671e8a.mp4",
 "thumbnail": "d2e3e9a311fcddcef9c907441c6ef916.jpg",
 "category": "タグなし",
 "tag": "タグなし",
 "value": "0",
 "memo": "none",
 "post_date": "2015-05-23 21:15:52",
 "cheer_flag": "0",
 "like_num": 5,
 "comment_num": 5,
 "follow_flag": 0,
 "like_flag": 1,
 "want_flag": 0
 },
 */

@interface EveryPost : NSObject

@property (nonatomic,copy) NSString *post_id;
@property (nonatomic,copy) NSString *post_user_id;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *profile_img;
@property (nonatomic,copy) NSString *post_rest_id;
@property (nonatomic,copy) NSString *restname;
@property (nonatomic,copy) NSString *movie;
@property (nonatomic,copy) NSString *thumbnail;
@property (nonatomic,copy) NSString *category;
@property (nonatomic,copy) NSString *tag;
@property (nonatomic,copy) NSString *value;
@property (nonatomic,copy) NSString *memo;
@property (nonatomic,copy) NSString *post_date;
@property (nonatomic,copy) NSString *cheer_flag;
@property (nonatomic) NSUInteger like_num;
@property (nonatomic) NSUInteger comment_num;
@property (nonatomic) NSUInteger follow_flag;
@property (nonatomic) NSUInteger like_flag;
@property (nonatomic) NSUInteger want_flag;


+ (instancetype)everyPostWithJsonDictionary:(NSDictionary *)dictionary;

@end
