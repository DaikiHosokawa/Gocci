//
//  Sample2TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Timeline;

@interface Sample2TableViewCell : UITableViewCell
@property (nonatomic, strong)Timeline *comment;


@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UIImageView *UsersPicture;
@property (weak, nonatomic) IBOutlet UILabel *UsersName;
@property (weak, nonatomic) IBOutlet UILabel *RestaurantName;
@property (weak, nonatomic) IBOutlet UILabel *Review;
@property (weak, nonatomic) IBOutlet UILabel *Goodnum;
@property (weak, nonatomic) IBOutlet UIView *contentViewFront;
@property (weak, nonatomic) Sample2TableViewCell *cell;
@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *Commentnum;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
//@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *Starnum;

@end
