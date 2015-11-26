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
#import "UsersViewController.h"

@class  MapViewController;

@protocol  MapViewControllerDelegate <NSObject>
//@optional
-(void)map:(MapViewController *)vc
           restid:(NSString*)restid;

@end

@interface MapViewController : UIViewController<GMSMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property id supervc;

@property (nonatomic, strong) NSDictionary *receiveDic3;
@property (nonatomic) CGRect soda;

@property (weak, nonatomic) IBOutlet GMSMapView *map;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property(nonatomic,strong) id<MapViewControllerDelegate> delegate;


@end
