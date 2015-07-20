//
//  FollowTableViewController.h
//  Gocci
//
//  Created by デザミ on 2015/06/17.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "usersTableViewController.h"
#import "usersTableViewController_other.h"
#import "RestaurantTableViewController.h"
#import "AppDelegate.h"
#import "CXCardView.h"
#import "DemoContentView.h"
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"
#import "BBBadgeBarButtonItem.h"

@class FollowTableViewController;

@protocol FollowTableViewControllerDelegate <NSObject>
//@optional
-(void)follow:(FollowTableViewController*)vc
	   postid:(NSString*)postid;

-(void)follow:(FollowTableViewController*)vc
  username:(NSString*)username picture:(NSString*)picture
		 flag:(NSInteger)flag;

-(void)follow:(FollowTableViewController*)vc
	 restname:(NSString*)restname
	 homepage:(NSString *)homepage
	 locality:(NSString *)locality
	 category:(NSString*)category
		  lon:(NSString*)lon
		  lat:(NSString*)lat
		 tell:(NSString*)tell
   totalcheer:(NSString*)totalcheer
	  wanttag:(NSString*)wanttag;
@end

@interface FollowTableViewController : UITableViewController<UIScrollViewDelegate>
{
	//commentへの引き継ぎ
	NSString *_postID;
	//profile_otherへの引き継ぎ
	NSString *_postUsername;
	NSString *_postPicture;
	NSInteger _postFlag;
	//restnameへの引き継ぎ
	NSString *_postRestname;
	//サムネイル
	UIImageView *thumbnailView;
}
@property(nonatomic,strong) id<FollowTableViewControllerDelegate> delegate;

@property (nonatomic, retain) UIImageView *thumbnailView;
@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;

@end
