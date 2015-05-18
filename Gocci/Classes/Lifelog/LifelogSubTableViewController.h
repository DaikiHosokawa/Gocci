//
//  usersTableViewController.h
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
#import "CXCardView.h"
#import "DemoContentView.h"

@interface LifelogSubTableViewController : UITableViewController<UIScrollViewDelegate>
{
    MPMoviePlayerController *moviePlayer;
    NSString *_postID;
    NSString *_postRestname;
    NSString *_postHomepage;
    NSString *_postLocality;
    NSString *_postTell;
    NSString *_postCategory;
    NSString *_postLat;
    NSString *_postLon;
    NSString *_postTotalCheer;
}

@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@property (nonatomic, retain) UIImageView *thumbnailView;
@end
