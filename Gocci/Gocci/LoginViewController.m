//
//  LoginViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>


@interface LoginViewController ()
- (IBAction)pushFacebook:(UIButton *)sender;
- (IBAction)pushTwitter:(UIButton *)sender;
@property ACAccount *facebookAccount;

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
    
    //ログインボタンを生成する
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 5);
    loginView.delegate = self;
    [self.view addSubview:loginView];
     
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO]; // ナビゲーションバー非表示

  
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
    if (self.accountStore == nil) {
        self.accountStore = [ACAccountStore new];
    }
    
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];  //  Facebookを指定
    NSDictionary *options = @{ ACFacebookAppIdKey : @"673123156062598",
                               ACFacebookAudienceKey : ACFacebookAudienceOnlyMe,
                               ACFacebookPermissionsKey : @[@"email"] };
    [self.accountStore
     requestAccessToAccountsWithType:accountType
     options:options
     completion:^(BOOL granted, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (granted) {
                 // ユーザーがFacebookアカウントへのアクセスを許可した
                 NSArray *facebookAccounts = [self.accountStore accountsWithAccountType:accountType];
                 if (facebookAccounts.count > 0) {
                     ACAccount *facebookAccount = [facebookAccounts lastObject];
                     
                     // メールアドレスを取得する
                     NSString *email = [[facebookAccount valueForKey:@"properties"] objectForKey:@"ACUIDisplayUsername"];
                     
                     // アクセストークンを取得する
                     ACAccountCredential *facebookCredential = [facebookAccount credential];
                     NSString *accessToken = [facebookCredential oauthToken];
                     NSLog(@"email:%@, token:%@", email, accessToken);

                     
                     //名前を取得する
                     NSString *fullname = [[facebookAccount valueForKey:@"properties"] objectForKey:@"fullname"];
                     NSLog(@"fullname:", fullname);
                     
                     //uidを取得する
                     NSString *uid = [[facebookAccount valueForKey:@"properties"] objectForKey:@"uid"];
                     NSLog(@"uid:", uid);
                     
                     //プロフィール画像を取得する
                     NSString *pictureURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", uid];
                     NSLog(@"%@", pictureURL); // プロフィール写真のURL
                     
                     //  ここでログイン処理などをする
                 }
             } else {
                 if([error code]== ACErrorAccountNotFound){
                     //  iOSに登録されているFacebookアカウントがありません。
                     NSLog(@"iOSにFacebookアカウントが登録されていません。設定→FacebookからFacebookアカウントを追加してください。");
                 } else {
                     // ユーザーが許可しない
                     // 設定→Facebook→アカウントの使用許可するApp→YOUR_APPをオンにする必要がある
                     NSLog(@"Facebookが有効になっていません。");
                 }
             }
         });
     }];
}


- (IBAction)pushTwitter:(UIButton *)sender {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Twitter ログインをユーザーがキャンセル");
            } else {
                NSLog(@"Twitter ログイン中にエラーが発生: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"Twitter サインアップ & ログイン完了!");
        } else {
            NSLog(@"Twitter ログイン完了!");
        }
    }];
}


@end