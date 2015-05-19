//
//  CustomTableViewCell.h
//  Gocci
//
//  Created by kim on 2015/05/16.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *notificationMessage;
@property (weak, nonatomic) IBOutlet UILabel *noticedAt;
+ (CGFloat)rowHeight;
@end
