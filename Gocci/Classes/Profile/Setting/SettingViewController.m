//
//  SettingViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/05.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "SettingViewController.h"
#import "APIClient.h"

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
    sectionList =  [NSArray arrayWithObjects:@"アカウント", @"ソーシャルネットワーク", @"サポート", nil];
    
    // セルの項目を作成する
    NSArray *peple = [NSArray arrayWithObjects:@"パスワードを設定する", @"通知", nil];
    NSArray *dogs = [NSArray arrayWithObjects:@"Twitter", @"Facebook", nil];
    NSArray *others = [NSArray arrayWithObjects:@"アドバイスを送る",@"利用規約",@"プライバシーポリシー",@"バージョン", nil];
    
    // セルの項目をまとめる
    NSArray *datas = [NSArray arrayWithObjects:peple, dogs, others, nil];
    
    dataSource = [NSDictionary dictionaryWithObjects:datas forKeys:sectionList];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
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
    NSLog(@"行数:%lu",[[dataSource objectForKey:sectionName ]count]);
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
    
    return cell;
}

/**
 * セルが選択されたとき
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row ==0){
            PASalertView = [[UIAlertView alloc] initWithTitle:@"パスワードを入力してください"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
            PASalertView.delegate       = self;
            PASalertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [PASalertView show];
        }else{
            NSLog(@"notice");
            //request permittion
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }
    else if (indexPath.section ==1){
        if (indexPath.row ==0) {
            NSLog(@"Twitter");
        }else{
            NSLog(@"Facebook");
        }
    }
    else if (indexPath.section == 2){
        if (indexPath.row ==0){
            NSLog(@"advice");
            ADValertView = [[UIAlertView alloc] initWithTitle:@"アドバイスを入力してください"
                                                        message:@"積極的に取り入れていきます"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
            ADValertView.delegate       = self;
            ADValertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [ADValertView show];
            
        }else if(indexPath.row == 1){
            NSLog(@"rule");
        //show Web view
        }else if (indexPath.row ==2){
            NSLog(@"privacy");
        //show privacy view
        }else{
            NSLog(@"version");
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(ADValertView == alertView){
        if( buttonIndex == alertView.cancelButtonIndex ) { return; }
        
        NSString* textValue = [[alertView textFieldAtIndex:0] text];
        if( [textValue length] > 0 )
        {
          //FEED BACK API
            NSLog(@"sent FeedBack");
        }
    }else if (PASalertView){
        if( buttonIndex == alertView.cancelButtonIndex ) { return; }
        
        NSString* textValue = [[alertView textFieldAtIndex:0] text];
        if( [textValue length] > 0 )
        {
            //PASSWORD API
            NSLog(@"sent password");
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

@end
