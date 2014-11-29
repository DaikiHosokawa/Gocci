//
//  usersTableViewController.h
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Sample5TableViewCell.h"
#import <Foundation/Foundation.h>
#import "RestaurantTableViewController.h"

@interface usersTableViewController : UITableViewController
{
    MPMoviePlayerController *moviePlayer;
    NSString *_postID;
    //restnameへの引き継ぎ
    NSString *_postRestname;
}

@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@end
