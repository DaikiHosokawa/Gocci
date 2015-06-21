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
@property (nonatomic) NSUInteger want_flag;
@property (nonatomic) NSString *pushed_at;
@property (nonatomic) NSInteger flag;


+ (instancetype)everyPostWithJsonDictionary:(NSDictionary *)dictionary;

@end
