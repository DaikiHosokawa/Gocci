//
//  TableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MypageViewController.h"

@class  TableViewController;

@protocol  TableViewControllerDelegate <NSObject>
//@optional
-(void)table:(TableViewController *)vc
      postid:(NSString*)postid;

-(void)table:(TableViewController *)vc
     rest_id:(NSString*)rest_id;

@end

@interface TableViewController : UITableViewController

@property id supervc;

@property (nonatomic, strong) NSMutableArray *receiveDic;
@property (nonatomic) CGRect soda;

@property(nonatomic,strong) id<TableViewControllerDelegate> delegate;

@end
