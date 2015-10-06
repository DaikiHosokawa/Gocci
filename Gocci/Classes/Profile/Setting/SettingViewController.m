//
//  SettingViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/05.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "SettingViewController.h"
#import "APIClient.h"
#import "PasswordPopup.h"
#import "rulePopup.h"
#import "PrivacyPopup.h"
#import "AdvicePopup.h"

@interface SettingViewController ()

@end

@implementation SettingViewController


/**
 * ビューがロードし終わったとき
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // セクション名を設定する
    sectionList =  [NSArray arrayWithObjects:@"アカウント", @"ソーシャルネットワーク", @"お知らせ", @"サポート", nil];
    
    // セルの項目を作成する
    NSArray *peple = [NSArray arrayWithObjects:@"パスワードを設定する" ,nil];
    NSArray *dogs = [NSArray arrayWithObjects:@"Twitter", @"Facebook",@"Google+", nil];
    NSArray *milk = [NSArray arrayWithObjects:@"通知を設定する", nil];
    NSArray *others = [NSArray arrayWithObjects:@"アドバイスを送る",@"利用規約",@"プライバシーポリシー",@"バージョン", nil];
    
    // セルの項目をまとめる
    NSArray *datas = [NSArray arrayWithObjects:peple, dogs,milk, others, nil];
    
    dataSource = [NSDictionary dictionaryWithObjects:datas forKeys:sectionList];
    
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}



- (void)showPopupWithTransitionStyle:(STPopupTransitionStyle)transitionStyle rootViewController:(UIViewController *)rootViewController
{
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:rootViewController];
    popupController.cornerRadius = 4;
    popupController.transitionStyle = transitionStyle;
    [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:0.20 green:0.60 blue:0.86 alpha:1.0];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Cochin" size:17] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}


/**
 * テーブル全体のセクションの数を返す
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionList count];
}

/**
 * 指定されたセクションのセクション名を返す
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionList objectAtIndex:section];
}

/**
 * 指定されたセクションの項目数を返す
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [sectionList objectAtIndex:section];
    return [[dataSource objectForKey:sectionName ]count];
}

/**
 * 指定された箇所のセルを作成する
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // セルが作成されていないか?
    if (!cell) { // yes
        // セルを作成
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // セクション名を取得する
    NSString *sectionName = [sectionList objectAtIndex:indexPath.section];
    
    // セクション名をキーにしてそのセクションの項目をすべて取得
    NSArray *items = [dataSource objectForKey:sectionName];
    
    // セルにテキストを設定
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

/**
 * セルが選択されたとき
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        
        if(indexPath.row ==0){
            
            NSLog(@"pass");
            [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[PasswordPopup new]];
        }
    }
    
    else if (indexPath.section ==1){
        if (indexPath.row ==0) {
            NSLog(@"Twitter");
        }else if (indexPath.row ==1){
            NSLog(@"Facebook");
        }else{
            NSLog(@"Google+");
        }
    }
    
    else if (indexPath.section == 2){
        if (indexPath.row ==0){
            NSLog(@"通知");
            //request permittion
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
        }
    }
    
    else if(indexPath.section == 3){
        
        if(indexPath.row == 0){
            NSLog(@"advice");
             [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[AdvicePopup new]];
        }else if(indexPath.row == 1){
            NSLog(@"rule");
            [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[rulePopup new]];
        }else if (indexPath.row == 2){
            NSLog(@"privacy");
             [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[PrivacyPopup new]];
        }else if (indexPath.row == 3){
            NSLog(@"version");
        }
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}


@end
