//
//  TimelineTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sample2TableViewCell.h"
#import "RNFrostedSidebar.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"


@interface TimelineTableViewController : UITableViewController{
    MPMoviePlayerController *moviePlayer;
    UITableViewCell *cell;
    NSString *_path;
}





@end
