//
//  FollowListViewController.h
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheerListCell.h"
#import <Foundation/Foundation.h>

@interface CheerListViewController : UITableViewController
{
    NSString *_postHomepage;
    NSString *_postLocality;
    NSString *_postRestname;
    NSString *_postTell;
    NSString *_postCategory;
    NSString *_postUsername;
}


@property (nonatomic) NSString *postHomepage;
@property (nonatomic) NSString *postLocality;
@property (nonatomic) NSString *postRestname;
@property (nonatomic) NSString *postTell;
@property (nonatomic) NSString *postCategory;
@property (nonatomic) NSString *postUsername;

@end
