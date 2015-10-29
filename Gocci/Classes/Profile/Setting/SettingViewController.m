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
    [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:17] } forState:UIControlStateNormal];
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
        
        if(indexPath.row == 0){
            
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

/*


#import "AdvicePopup.h"
#import "STPopup.h"
#import "CompletePopup.h"
#import "APIClient.h"

@interface AdvicePopup () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@end


@implementation AdvicePopup
{
    UILabel *_label;
    UIView *_separatorView;
    UITextField *_textField;
    UIImageView *_imageView;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.contentSizeInPopup = CGSizeMake(300, 100);
        self.landscapeContentSizeInPopup = CGSizeMake(300, 200);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _label = [UILabel new];
    _label.numberOfLines = 0;
    _label.text = @"下に意見/要望をご入力ください";
    _label.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
    _separatorView = [UIView new];
    _separatorView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_separatorView];
    
    _textField = [UITextField new];
    _textField.delegate = self;
    _textField.placeholder = @"ここに入力";
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_textField];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _textField.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    _separatorView.frame = CGRectMake(0, _textField.frame.origin.y - 0.5, self.view.frame.size.width, 0.5);
    _label.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, self.view.frame.size.height - 20 - _textField.frame.size.height);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text:%@",textField.text);
    
    if([textField.text length] > 0 ){
        
        [APIClient postFeedback:textField.text handler:^(id result, NSUInteger code, NSError *error) {
            if (code == 200){
                [textField resignFirstResponder];
                [self.popupController pushViewController:[CompletePopup new] animated:YES];
            }
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
        }
         ];
    }else{
        _label.text = @"1文字以上入力してください";
        _label.textColor = [UIColor redColor];
    }
    
    return NO;
}

@end





/*


//
//  PopupViewController3.m
//  STPopup
//
//  Created by Kevin Lin on 13/9/15.
//  Copyright (c) 2015 Sth4Me. All rights reserved.
//

#import "AdvicePopup.h"
#import "STPopup.h"
#import "CompletePopup.h"
#import "APIClient.h"

@interface AdvicePopup () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@end


@implementation AdvicePopup
{
    UILabel *_label;
    UIView *_separatorView;
    UITextField *_textField;
    UIImageView *_imageView;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.contentSizeInPopup = CGSizeMake(300, 100);
        self.landscapeContentSizeInPopup = CGSizeMake(300, 200);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _label = [UILabel new];
    _label.numberOfLines = 0;
    _label.text = @"下に意見/要望をご入力ください";
    _label.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
    _separatorView = [UIView new];
    _separatorView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_separatorView];
    
    _textField = [UITextField new];
    _textField.delegate = self;
    _textField.placeholder = @"ここに入力";
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_textField];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _textField.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    _separatorView.frame = CGRectMake(0, _textField.frame.origin.y - 0.5, self.view.frame.size.width, 0.5);
    _label.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, self.view.frame.size.height - 20 - _textField.frame.size.height);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text:%@",textField.text);
    
    if([textField.text length] > 0 ){
        
        [APIClient postFeedback:textField.text handler:^(id result, NSUInteger code, NSError *error) {
            if (code == 200){
                [textField resignFirstResponder];
                [self.popupController pushViewController:[CompletePopup new] animated:YES];
            }
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
        }
         ];
    }else{
        _label.text = @"1文字以上入力してください";
        _label.textColor = [UIColor redColor];
    }
    
    return NO;
}

@end
decadeaf ~/Documents/ios %
*/