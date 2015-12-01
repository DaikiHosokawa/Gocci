//
//  HeatMapViewController.m
//  Gocci
//
//  Created by Castela on 2015/11/30.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "HeatMapViewController.h"

@interface HeatMapViewController ()

@end

@implementation HeatMapViewController

- (void)viewWillAppear:(BOOL)animated{
     [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc]init];
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter=10.0;
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services not available.");
    }

    self.map.delegate = self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
                                                            longitude:newLocation.coordinate.longitude
                                                                 zoom:16.0];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:newLocation.coordinate];
    marker.draggable = YES;
    marker.map = self.map;
    self.map.camera = camera;
    NSLog(@"didUpdateToLocation latitude=%f, longitude=%f",
          [newLocation coordinate].latitude,
          [newLocation coordinate].longitude);
        });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//ドラッグ開始
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker{
}

//ドラッグ中
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker{
    NSLog(@"marker position(before):%f,%f",marker.position.latitude,marker.position.longitude);
}

//ドラッグ終了
- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker{
    
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
