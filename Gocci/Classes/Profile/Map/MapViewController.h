//
//  MapViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/05.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController<GMSMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property id supervc;

@property (nonatomic, strong) NSDictionary *receiveDic3;
@property (nonatomic) CGRect soda;


@end
