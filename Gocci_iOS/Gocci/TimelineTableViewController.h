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
#import "SVProgressHUD/SVProgressHUD.h"



@interface TimelineTableViewController : UITableViewController<UIScrollViewDelegate>

{
    NSString *_postID;
    NSString *_postRestname;
    NSString *_postUsername;
    
    MPMoviePlayerController *moviePlayer;
  
    NSString *_path;
    Sample2TableViewCell  *cell;
    UIImageView *thumbnailView;
}

@property (nonatomic, retain) NSString *postID;
@property (nonatomic, retain) Sample2TableViewCell *cell;
@property (nonatomic, retain) UIImageView *thumbnailView;

@end
