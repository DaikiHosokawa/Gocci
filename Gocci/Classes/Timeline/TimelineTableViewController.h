    //
    //  TimelineTableViewController.h
    //  Gocci
    //
    //  Created by Daiki Hosokawa on 2014/05/10.
    //  Copyright (c) 2014年 Massara. All rights reserved.
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

    @interface TimelineTableViewController : UITableViewController<UIScrollViewDelegate>
    {
        //commentへの引き継ぎ
        NSString *_postID;
        //profile_otherへの引き継ぎ
        NSString *_postUsername;
        NSString *_postPicture;
        NSInteger _postFlag;
        //restnameへの引き継ぎ
        NSString *_postRestname;
        NSString *_postHomepage;
        NSString *_postLocality;
        NSString *_postCategory;
        NSString *_postLon;
        NSString *_postLat;
        NSString *_postTell;
        NSString *_postTotalCheer;
        NSString *_postWanttag;
        //サムネイル
        UIImageView *thumbnailView;
    }

    @property (nonatomic, retain) UIImageView *thumbnailView;
    @property (strong, nonatomic) WYPopoverController *popover;
    @property (strong, nonatomic) BBBadgeBarButtonItem *barButton;

    @end
