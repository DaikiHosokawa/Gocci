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
#import "CollectionViewController.h"


@interface everyTableViewController : UITableViewController<UITextViewDelegate, UITabBarControllerDelegate>
{
    NSString *_postID;
    //profile_otherへの引き継ぎ
    NSString *_postUsername;
    NSString *_postPicture;
    NSInteger _postFlag;
    //restnameへの引き継ぎ
    NSString *_postRestname;
}

-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag;
@property (nonatomic) NSString *postID;

// !!!:dezamisystem
- (IBAction)onReturn:(id)sender;
- (void)goUsersDelegate:(NSString *)userName picture:(NSString *)usersPicture flag:(NSInteger)flag;


@end
