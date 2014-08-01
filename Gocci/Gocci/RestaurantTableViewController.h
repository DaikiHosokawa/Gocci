//
//  RestaurantTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Sample3TableViewCell.h"
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RestaurantTableViewController : UITableViewController{
    MPMoviePlayerController *moviePlayer;
    UITableViewCell *cell;
}


-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag;

@end
