//
//  TimelineTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sample2TableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>



@interface TimelineTableViewController : UITableViewController<UIScrollViewDelegate>
{
    CLLocationManager *locationManager;
    double latitude, longitude; // 取得した緯度経度
    MPMoviePlayerController *moviePlayer;
    UITableViewCell *cell;
    NSString *_path;
    NSString *lat;
    NSString *lon;
}
-(void) onResume;
-(void) onPause;

@property (nonatomic, retain) CLLocationManager *locationManager;





@end
