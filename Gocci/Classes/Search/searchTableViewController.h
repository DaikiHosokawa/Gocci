//
//  SearchTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewController : UITableViewController
{
    NSString *_postRestName;
    NSString *_headerLocality;
    NSString *annotationTitle;
    NSString *annotationSubtitle;
}

@property (nonatomic, strong) NSString *headerLocality;
@property (nonatomic, strong) NSString *postRestName;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@end




