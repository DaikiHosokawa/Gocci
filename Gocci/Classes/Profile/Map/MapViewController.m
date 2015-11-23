//
//  MapViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/05.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "MapViewController.h"
#import "APIClient.h"

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@interface MapViewController (){
    
}

@end

@implementation MapViewController

- (void)viewWillAppear:(BOOL)animated{
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc]init];
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter=10.0;
        [self addMarkersToMap];
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services not available.");
    }
    
    self.map.delegate = self;
    self.map.myLocationEnabled = YES;
    self.map.settings.myLocationButton = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
                                                            longitude:newLocation.coordinate.longitude
                                                                 zoom:16.0];
    self.map.camera = camera;
        NSLog(@"didUpdateToLocation latitude=%f, longitude=%f",
          [newLocation coordinate].latitude,
          [newLocation coordinate].longitude);
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}

- (void)addMarkersToMap {
    
    NSArray* items = (NSArray*)_receiveDic3;
    
    if ([items count] == 0) {
        
        
    }else{
        
        NSArray *markerInfos = items    ;
        
        for (NSDictionary *markerInfo in markerInfos) {
            
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([markerInfo[@"Y(lon_lat)"] doubleValue], [markerInfo[@"X(lon_lat)"] doubleValue]);
            marker.title = markerInfo[@"restname"];
            marker.snippet = markerInfo[@"post_date"];
            marker.userData = markerInfo[@"post_id"];
            marker.infoWindowAnchor = CGPointMake(0.5, 0.25);
            marker.groundAnchor = CGPointMake(0.5, 1.0);
            marker.map = self.map;
            
        }
    }
}


- (IBAction)tapBackButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:marker.userData];
    
}
@end
