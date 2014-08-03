//
//  SearchTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SampleTableViewCell.h"
#import <CoreLocation/CoreLocation.h>



@interface SearchTableViewController : UITableViewController{
    CLLocationManager *locationManager;
}

-(void) onResume;
-(void) onPause;

@property (nonatomic, retain) CLLocationManager *locationManager;
@end




