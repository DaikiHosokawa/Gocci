//
//  TableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserpageViewController.h"

@class  TableViewController_2;

@protocol  TableViewController_2Delegate <NSObject>
//@optional
-(void)table:(TableViewController_2 *)vc
      postid:(NSString*)postid;

-(void)table:(TableViewController_2 *)vc
     rest_id:(NSString*)rest_id;

@end

@interface TableViewController_2 : UITableViewController

@property id supervc;

@property (nonatomic, strong) NSMutableArray *receiveDic;
@property (nonatomic) CGRect soda;

@property(nonatomic,strong) id<TableViewController_2Delegate> delegate;

@end
