//
//  SearchTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchTableViewController : UITableViewController<CLLocationManagerDelegate>
{
    NSString *_postRestName;
    NSString *_headerLocality;
    NSString *annotationTitle;
    NSString *annotationSubtitle;
    // ロケーションマネージャー
    CLLocationManager* locationManager;
    
    CLLocation *testLocation;
}

@property (nonatomic, strong) NSString *headerLocality;
@property (nonatomic, strong) NSString *postRestName;
@property (nonatomic) CLLocation *testLocation;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@end




