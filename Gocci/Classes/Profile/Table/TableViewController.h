//
//  TableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersViewController.h"

@interface TableViewController : UITableViewController

@property id supervc;

@property (nonatomic, strong) NSDictionary *receiveDic;
@property (nonatomic) CGRect soda;

@end
