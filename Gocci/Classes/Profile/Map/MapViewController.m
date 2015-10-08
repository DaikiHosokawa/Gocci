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
    
    [self _fetchProfile];
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    //ここをどうするか
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:35.689521
                                                                    longitude:139.691704
                                                                         zoom:12.0f];
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds
                                     camera:cameraPosition];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_fetchProfile
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
        thats  = (NSArray*)_receiveDic3;
        NSLog(@"thats:%@",thats);
        if ([thats count] == 0) {
            // 画像表示例文
            UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
            UIImageView *iv = [[UIImageView alloc] initWithImage:img];
            CGSize boundsSize = self.view.bounds.size;
            iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
            [self.view addSubview:iv];
        }else{
            [self.view addSubview:self.mapView];
            [self addMarkersToMap];
 }
}

- (void)addMarkersToMap {
    
    NSArray *markerInfos = thats;
    
    for (NSDictionary *markerInfo in markerInfos) {
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        
        marker.position = CLLocationCoordinate2DMake([markerInfo[@"Y(lon_lat)"] doubleValue], [markerInfo[@"X(lon_lat)"] doubleValue]);
        marker.title = markerInfo[@"restname"];
        marker.snippet = markerInfo[@"post_date"];
        NSURL *url = [NSURL URLWithString:markerInfo[@"thumbnail"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img_mae = [UIImage imageWithData:data];
        UIImage *img_ato;  // リサイズ後UIImage
        CGFloat width = 50;  // リサイズ後幅のサイズ
        CGFloat height = 50;  // リサイズ後高さのサイズ
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [img_mae drawInRect:CGRectMake(0, 0, width, height)];
        img_ato = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        marker.icon = img_ato;
        marker.userData = markerInfo[@"post_id"];
        marker.infoWindowAnchor = CGPointMake(0.5, 0.25);
        marker.groundAnchor = CGPointMake(0.5, 1.0);
        
        marker.map = self.mapView;
    }
}



- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    NSLog(@"何をタップしてるんだ:%@",marker.userData);
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