//
//  Sample4TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Sample4TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *UsersPicture;
@property (weak, nonatomic) IBOutlet UILabel *UsersName;
@property (weak, nonatomic) IBOutlet UILabel *Comment;
@property (weak, nonatomic) IBOutlet UILabel *DateOfComment;

#pragma mark - Value
+(CGFloat)heightCell;

#pragma mark - Initialize
+ (instancetype)cell;

@end
