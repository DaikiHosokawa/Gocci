//
//  everyTableViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Sample4TableViewCell.h"
#import <Foundation/Foundation.h>
#import "Sample4TableViewCell.h"


@interface everyTableViewController : UITableViewController<UITextViewDelegate>{
     NSString *_postID;
}

-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag;
@property (nonatomic) NSString *postID;

@end
