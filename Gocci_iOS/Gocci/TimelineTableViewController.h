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
#import "usersTableViewController.h" 
#import "usersTableViewController_other.h"
#import "AppDelegate.h"



@interface TimelineTableViewController : UITableViewController<UIScrollViewDelegate>

{
    NSString *_postID;
    NSString *_postRestname;
    //profile_otherへの引き継ぎ
    NSString *_postUsername;
    NSString *_postPicture;
    
    MPMoviePlayerController *moviePlayer;
  
    NSString *_path;
    Sample2TableViewCell  *cell;
    UIImageView *thumbnailView;
}

-(void) onResume;
-(void) onPause;
@property (nonatomic, retain) NSString *postID;
@property (nonatomic, retain) Sample2TableViewCell *cell;
@property (nonatomic, retain) UIImageView *thumbnailView;

@end
