//
//  EveryPost.h
//  Gocci
//
//  Created by デザミ on 2015/06/12.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>


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
@property (nonatomic) NSString* want_flag;
@property (nonatomic) NSString *pushed_at;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSString* lat;
@property (nonatomic) NSString* lon;
@property (nonatomic, copy) NSString *locality;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *homepage;
@property (nonatomic, copy) NSString *total_cheer_num;
@property (nonatomic, copy) NSString *tag_category;
@property (nonatomic, copy) NSString *atmosphere;

+ (instancetype)everyPostWithJsonDictionary:(NSDictionary *)dictionary;

@end
