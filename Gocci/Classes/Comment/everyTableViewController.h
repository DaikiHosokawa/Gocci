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


@interface everyTableViewController : UIViewController<UITextViewDelegate, UITabBarControllerDelegate,UITextFieldDelegate,UITableViewDelegate>
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

@property(nonatomic,retain) NSMutableArray *listUsername;
@property(nonatomic,retain) NSMutableArray *listProfileImg;
@property(nonatomic,retain) NSMutableArray *listComment;
@property(nonatomic,retain) NSMutableArray *listDate;

// !!!:dezamisystem
- (IBAction)onReturn:(id)sender;


@end
