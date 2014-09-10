//
//  Sample2TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface Sample2TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *UsersPicture;
@property (weak, nonatomic) IBOutlet UILabel *UsersName;
@property (weak, nonatomic) IBOutlet UILabel *RestaurantName;
@property (weak, nonatomic) IBOutlet UILabel *Review;
@property (weak, nonatomic) IBOutlet UILabel *Goodnum;
@property (weak, nonatomic) IBOutlet UIView *contentViewFront;
@property (weak, nonatomic) Sample2TableViewCell *cell;
@property (weak, nonatomic) IBOutlet UIView *movieView;

@end
