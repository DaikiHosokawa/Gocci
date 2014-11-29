//
//  usersTableViewController_other.h
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Sample5TableViewCell_other.h"
#import <Foundation/Foundation.h>

@interface usersTableViewController_other : UITableViewController
{
    NSString *_postUsername;
    MPMoviePlayerController *moviePlayer;
    NSString *_postID;
    NSString *_postRestName;
    NSString *_postPicture;
}

@property (nonatomic, retain) NSString *postID;
@property (nonatomic) NSString *postRestName;
@property (nonatomic) NSString *postUsername;
@property (nonatomic) NSString *postPicture;
@end
