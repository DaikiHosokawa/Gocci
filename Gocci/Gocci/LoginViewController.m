//
//  LoginViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
- (IBAction)pushFacebook:(UIButton *)sender;
- (IBAction)pushTwitter:(UIButton *)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pushFacebook:(UIButton *)sender {
    
}


- (IBAction)pushTwitter:(UIButton *)sender {
    NSString *accountTypeIdentifier = ACAccountTypeIdentifierTwitter;   // Twitter
    
    // ソーシャルメディアのアカウント情報を管理するクラス
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];
    
    // アカウントが設定されているかチェック
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if ([accounts count] > 0) {
                // Twitterアカウントは複数設定できるがとりあえず最初のを使用する
                ACAccount *account = accounts[0];
                
                // TwitterのWeb API
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
                
                // パラメータを設定
                NSDictionary *params = @{@"status" : @"アプリからの投稿"};
                
                // リクエストを組み立てる
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:params];
                
                // アカウントの設定
                request.account = account;
                
                // リクエスト送信
                [request performRequestWithHandler:
                 ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                     NSLog(@"status code : %ld", (long)[urlResponse statusCode]);
                 }];
            }
        }
    }];
}

@end
