//
//  SearchTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"
#import "CXCardView.h"

@interface SearchTableViewController : UITableViewController
{
    NSString *_postRestName;
    NSString *_headerLocality;
    CLLocationCoordinate2D coordinate;
    NSString *annotationTitle;
    NSString *annotationSubtitle;
}

@property (nonatomic, strong) NSString *headerLocality;
@property (nonatomic, strong) NSString *postRestName;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end




