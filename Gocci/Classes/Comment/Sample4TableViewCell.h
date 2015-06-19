//
//  Sample4TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Sample4TableViewCellDelegate <NSObject>

@end

@interface Sample4TableViewCell : UITableViewCell
@property (nonatomic, weak) id<Sample4TableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *UsersPicture;
@property (weak, nonatomic) IBOutlet UILabel *UsersName;
@property (weak, nonatomic) IBOutlet UILabel *Comment;
@property (weak, nonatomic) IBOutlet UILabel *DateOfComment;

#pragma mark - Value
+(CGFloat)heightCell;

#pragma mark - Initialize
+ (instancetype)cell;



@end
