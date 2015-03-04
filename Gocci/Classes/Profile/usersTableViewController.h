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

@interface usersTableViewController : UITableViewController
{
    MPMoviePlayerController *moviePlayer;
    NSString *_postID;
    NSString *_postRestname;
    NSString *_postHomepage;
    NSString *_postLocality;
    NSString *_postTell;

}

@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@property (nonatomic, retain) UIImageView *thumbnailView;
@end
