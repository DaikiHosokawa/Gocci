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
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"
#import "BBBadgeBarButtonItem.h"

@interface RestaurantTableViewController : UITableViewController <MKAnnotation,UIActionSheetDelegate>
{
   
    //from SearchTableVIew
    NSString *_postRestName;
    NSString *_postUsername;
    
    NSString *_postID;
    NSString *lat;
    NSString *lon;
    
     int flash_on;
}

@property (readwrite, nonatomic) CLLocationCoordinate2D coordinate; // required
@property IBOutlet UIButton *flashBtn;
@property (weak, nonatomic) IBOutlet GMSMapView *map;
@property (nonatomic, retain) UIImageView *thumbnailView;
@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag;
@property (weak, nonatomic) IBOutlet UILabel *restname;
@property (weak, nonatomic) IBOutlet UIView *restview;
@property (weak, nonatomic) IBOutlet UILabel *total_cheer_num;

@property (weak, nonatomic) IBOutlet UIView *emptyView;

@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;

@end
