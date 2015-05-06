//
//  usersTableViewController_other.h
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import <Foundation/Foundation.h>
#import "RestaurantTableViewController.h"
#import "AppDelegate.h"
#import "FollowListViewController.h"
#import "FolloweeListViewController.h"



@interface usersTableViewController_other : UITableViewController
{
    NSString *_postUsername;
    //MPMoviePlayerController *moviePlayer;
    NSString *_postID;
    NSString *_postPicture;
    //restnameへの引き継ぎ
    NSString *_postRestname;
    NSString *_postHomepage;
    NSString *_postLocality;
    NSString *_postTell;
    NSString *_postCategory;
    NSString *_postUsername_with_profile;
    NSString *_postUserPicture_with_profile;
    NSString *_postUsername_with_profile2;
    NSString *_postUserPicture_with_profile2;

    int flash_on;

}

@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@property (nonatomic) NSString *postUsername;
@property (nonatomic) NSString *postPicture;
@property (nonatomic) NSString *postUsername_with_profile;
@property (nonatomic) NSString *postUserPicture_with_profile;
@property (nonatomic) NSString *postUsername_with_profile2;
@property (nonatomic) NSString *postUserPicture_with_profile2;

@property IBOutlet UIButton *flashBtn;
@property (nonatomic, retain) UIImageView *thumbnailView;
@end
