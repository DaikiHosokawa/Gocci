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


@interface usersTableViewController_other :  UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSString *_postUsername;
    NSString *_postID;
    //restnameへの引き継ぎ
    NSString *_postRestname;
    
    int flash_on;

}

@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@property (nonatomic) NSString *postUsername;

@property IBOutlet UIButton *flashBtn;
@property (nonatomic, retain) UIImageView *thumbnailView;

@end
