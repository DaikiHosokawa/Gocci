//
//  RestaurantTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa.
//  Copyright (c) 2014年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "usersTableViewController_other.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"

@interface RestaurantTableViewController : UITableViewController <MKAnnotation,UIActionSheetDelegate>
{
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
@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@property (weak, nonatomic) IBOutlet UILabel *restname;
@property (weak, nonatomic) IBOutlet UIView *restview;
@property (weak, nonatomic) IBOutlet UILabel *total_cheer_num;
@property (strong, nonatomic) WYPopoverController *popover;

@end
