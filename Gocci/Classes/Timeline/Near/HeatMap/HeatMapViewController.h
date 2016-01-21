//
//  HeatMapViewController.h
//  Gocci
//
//  Created by Castela on 2015/11/30.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface HeatMapViewController000 : UIViewController<GMSMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property id supervc;

@property (nonatomic, strong) NSDictionary *receiveDic3;
@property (nonatomic) CGRect soda;

@property (weak, nonatomic) IBOutlet GMSMapView *map;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end
