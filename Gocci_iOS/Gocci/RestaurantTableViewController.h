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
#import "Sample3TableViewCell.h"
#import <Foundation/Foundation.h>
#import "usersTableViewController_other.h"
#import <MediaPlayer/MediaPlayer.h>

@interface RestaurantTableViewController : UITableViewController

{
    MPMoviePlayerController *moviePlayer;
    UITableViewCell *cell;
    NSString *_postRestName;
    //profile_otherへの引き継ぎ
    NSString *_postUsername;
    NSString *_postPicture;

    NSString *_headerLocality;
    NSString *_postID;
}

@property (nonatomic, retain) UIImageView *thumbnailView;
@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@property (nonatomic) NSString *headerLocality;
-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag;
@property (weak, nonatomic) IBOutlet UILabel *restname;
@property (weak, nonatomic) IBOutlet UILabel *locality;
@property (weak, nonatomic) IBOutlet UIView *restview;

@end
