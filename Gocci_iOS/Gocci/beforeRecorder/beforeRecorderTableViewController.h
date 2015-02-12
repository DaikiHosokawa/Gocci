//
//  beforeRecorderTableViewController.h
//  Gocci
//
//  Created by デザミ on 2015/02/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface beforeRecorderTableViewController : UITableViewController <CLLocationManagerDelegate>
{
    // ロケーションマネージャー
    CLLocationManager* locationManager;
}


@end
