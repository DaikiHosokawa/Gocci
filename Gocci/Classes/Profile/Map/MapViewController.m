//
//  MapViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/05.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "MapViewController.h"
#import "APIClient.h"
#import "InfoView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Dummy.h"
#import "everyTableViewController.h"

static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";

@interface MapViewController (){
    
}

@end

@implementation MapViewController

- (void)viewWillAppear:(BOOL)animated{
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    
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
            marker.userData = markerInfo;
            marker.infoWindowAnchor = CGPointMake(0.44f, -0.4f);
            marker.icon = [UIImage imageNamed:@"pin"];
            marker.map = self.map;
            
        }
    }
}
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    InfoView *view =  [[[NSBundle mainBundle] loadNibNamed:@"InfoView" owner:self options:nil] objectAtIndex:0];
    [view.thumbnail sd_setImageWithURL:[NSURL URLWithString:marker.userData[@"thumbnail"]]
                            placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    view.restname.text = marker.userData[@"restname"];
    view.timelabel.text = marker.userData[@"post_date"];
    return view;
}



- (IBAction)tapBackButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    [self performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:marker.userData[@"rest_id"]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        RestaurantTableViewController *restVC = segue.destinationViewController;
        restVC.postRestName = (NSString *)sender;
    }
    
}
@end
