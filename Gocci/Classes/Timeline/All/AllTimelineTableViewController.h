//
//  AllTimelineTableViewController.h
//  Gocci
//
//  Created by INASE on 2015/06/17.
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
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"
#import "BBBadgeBarButtonItem.h"

@class AllTimelineTableViewController;

@protocol AllTimelineTableViewControllerDelegate <NSObject>
//@optional
-(void)allTimeline:(AllTimelineTableViewController*)vc
				 postid:(NSString*)postid;

-(void)allTimeline:(AllTimelineTableViewController*)vc
			   username:(NSString*)user_id;

-(void)allTimeline:(AllTimelineTableViewController*)vc
		   rest_id:(NSString*)rest_id;
			   
@end

@interface AllTimelineTableViewController : UITableViewController<UIScrollViewDelegate>
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
@property(nonatomic,strong) id<AllTimelineTableViewControllerDelegate> delegate;

@property (nonatomic, retain) UIImageView *thumbnailView;
@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;

@end
