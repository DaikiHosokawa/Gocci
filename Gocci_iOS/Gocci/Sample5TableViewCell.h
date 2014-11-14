//
//  Sample5TableViewCell.h
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Sample5TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *UsersPicture;
@property (weak, nonatomic) IBOutlet UILabel *UsersName;
@property (weak, nonatomic) IBOutlet UILabel *RestaurantName;
@property (weak, nonatomic) IBOutlet UILabel *Review;
@property (weak, nonatomic) IBOutlet UILabel *Goodnum;
@property (weak, nonatomic) IBOutlet UIView *contentViewFront;
@property (weak, nonatomic) Sample5TableViewCell *cell;
@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *Commentnum;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UILabel *starnum;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIImageView *starImage;

@end
