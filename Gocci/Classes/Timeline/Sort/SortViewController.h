//
//  SortViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/13.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelinePageMenuViewController.h"
#import "CategoryViewController.h"

@interface SortViewController : UITableViewController{
    NSString *category;
    NSString *value;
    NSString *category_flag;
    NSString *value_flag;
}

@property (weak, nonatomic) TimelinePageMenuViewController *timelinePageMenuViewController;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *value;
@property (nonatomic) NSString *category_flag;
@property (nonatomic) NSString *value_flag;


@end
