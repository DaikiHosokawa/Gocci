//
//  CollectionViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FollowViewController;

@protocol FollowViewControllerDelegate <NSObject>
//@optional
-(void)follow:(FollowViewController*)vc
            postid:(NSString*)postid;

-(void)follow:(FollowViewController *)vc
          username:(NSString*)user_id;

-(void)follow:(FollowViewController *)vc
           rest_id:(NSString*)rest_id;

@end

@interface FollowViewController : UICollectionViewController

@property id supervc; //親
@property(nonatomic,strong) id<FollowViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

- (void)sortFunc:(NSString *)category;
- (void)sortValue:(NSString *)value;

@end


