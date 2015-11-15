//
//  MapViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/05.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "MapViewController.h"
#import "APIClient.h"


static NSString * const TitleKey = @"title";
static NSString * const InfoKey = @"info";
static NSString * const LatitudeKey = @"latitude";
static NSString * const LongitudeKey = @"longitude";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@interface MapViewController (){
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *lat;
    NSMutableArray *lon;
    NSMutableArray *restname;
    NSMutableArray *category;
    NSArray *thats;
}

@property (strong, nonatomic) GMSMapView *mapView;

@end

@implementation MapViewController

- (void)viewWillAppear:(BOOL)animated{
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.view.frame = self.soda;
    
    
    //ここをどうするか
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:35.689521
                                                                    longitude:139.691704
                                                                         zoom:12.0f];
//    [self.mapView setFrame:self.view.bounds];
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds
                                     camera:cameraPosition];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.view = self.mapView;
    locationManager = [[CLLocationManager alloc]init];
    
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter=10.0;
        [self addMarkersToMap];
        // 測位開始
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services not available.");
    }
    //self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
   
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 位置情報更新時
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.mapView animateToLocation : [newLocation coordinate]];
    
    //緯度・経度を出力
    NSLog(@"didUpdateToLocation latitude=%f, longitude=%f",
          [newLocation coordinate].latitude,
          [newLocation coordinate].longitude);
}

// 測位失敗時や、位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}


- (void)addMarkersToMap {
    
     NSArray* items = (NSArray*)_receiveDic3;
    
    if ([items count] == 0) {
        // 画像表示例文
        UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        CGSize boundsSize = self.soda.size;
        iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
        [self.view addSubview:iv];
        
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
        
        marker.map = self.mapView;
        
    }
    }
}



- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{

    [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:marker.userData];

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
