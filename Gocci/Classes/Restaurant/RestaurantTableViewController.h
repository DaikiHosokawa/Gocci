//
//  RestaurantTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Foundation/Foundation.h>
#import "usersTableViewController_other.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CXCardView.h"
#import "DemoContentView.h"

@interface RestaurantTableViewController : UITableViewController
{
    //profile_otherへの引き継ぎ
    NSString *_postUsername;
    NSString *_postPicture;
    //from SearchTableVIew
    NSString *_postRestName;
    //
    NSString *_postLocality;
    NSString *_postTell;
    NSString *_postHomepage;
    NSString *_headerLocality;
    NSString *_postLat;
    NSString *_postLon;
    
    NSString *_postID;
    NSString *lat;
    NSString *lon;
}

@property (nonatomic, retain) UIImageView *thumbnailView;
@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@property (nonatomic) NSString *postLocality;
@property (nonatomic) NSString *postTell;
@property (nonatomic) NSString *postHomepage;
@property (nonatomic) NSString *headerLocality;
@property (nonatomic) NSString *postLat;
@property (nonatomic) NSString *postLon;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lon;
-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag;
@property (weak, nonatomic) IBOutlet UILabel *restname;
@property (weak, nonatomic) IBOutlet UILabel *locality;
@property (weak, nonatomic) IBOutlet UIView *restview;


@end
