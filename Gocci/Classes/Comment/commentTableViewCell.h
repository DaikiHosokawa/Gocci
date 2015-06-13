//
//  commentTableViewCell.h
//  Gocci
//
//  Created by デザミ on 2015/06/13.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const CommentCellIdentifier;

@interface commentTableViewCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate>

#pragma mark - 反映
-(void)configureWithArray:(NSArray*)commentlist;

+(CGFloat)heightCell;

#pragma mark - Initialize
+ (instancetype)cell;

@end
