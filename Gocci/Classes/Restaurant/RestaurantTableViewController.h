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

@interface RestaurantTableViewController : UITableViewController <MKAnnotation,UIActionSheetDelegate>
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
    NSString *_postCategory;
    
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
@property (nonatomic) NSString *postLocality;
@property (nonatomic) NSString *postTell;
@property (nonatomic) NSString *postHomepage;
@property (nonatomic) NSString *postCategory;
@property (nonatomic) NSString *postLon;
@property (nonatomic) NSString *postLat;
-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag;
@property (weak, nonatomic) IBOutlet UILabel *restname;
@property (weak, nonatomic) IBOutlet UILabel *locality;
@property (weak, nonatomic) IBOutlet UIView *restview;
@property (weak, nonatomic) IBOutlet UIButton *cheerNumBtn;

@property (weak, nonatomic) IBOutlet UIView *emptyView;


@end
