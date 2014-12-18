//
//  ProfilePost.h
//  Gocci
//
//  Created by Jack O' Lantern on 2014/12/05.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfilePost : NSObject

@property(nonatomic) NSUInteger commentNum;
@property(nonatomic) NSUInteger goodNum;
@property(nonatomic )  NSInteger badNum;
@property(nonatomic,strong) NSString *locality;
@property(nonatomic,strong) NSString *movie;
@property(nonatomic,strong) NSString *picture;
@property(nonatomic,strong) NSString *postID;
@property(nonatomic,strong) NSString *restname;
@property(nonatomic) NSUInteger starEvaluation;
@property(nonatomic,strong) NSString *thumbnail;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) NSString *userName;

+ (instancetype)profilePostWithDictionary:(NSDictionary *)dictionary;


@end
