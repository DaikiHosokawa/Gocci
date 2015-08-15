//
//  commentTableViewCell.h
//  Gocci
//
//  Created by INASE on 2015/06/13.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "everyTableViewController.h"

extern NSString * const CommentCellIdentifier;
extern NSString * const CommentAllCellIdentifier;

@protocol everyTableViewControllerDelegate <NSObject>

@end

@interface commentTableViewCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate>

@property id supervc; //親

#pragma mark - 反映
-(void)configureWithArray:(NSArray*)commentlist;

+(CGFloat)heightCell;

#pragma mark - Initialize
+ (instancetype)cell;

@end
