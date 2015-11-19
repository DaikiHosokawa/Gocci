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
#import "CollectionViewController.h"

@interface UsersViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSString *_postID;
    NSString *_postRestname;
    int flash_on;

}


@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;


@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;


@end
