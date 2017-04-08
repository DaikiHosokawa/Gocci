//
//  EditTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/23.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface informationController : UITableViewController{
    NSString *restname;
    NSString *restid;
    NSString *category;
    NSString *value;
    NSString *category_flag;
    NSString *lat;
    NSString *lon;
}


@property (nonatomic) NSString *restname;
@property (nonatomic) NSString *restid;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *value;
@property (nonatomic) NSString *category_flag;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lon;



@end
