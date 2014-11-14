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
#import "TimelineTableViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface LoginViewController ()
- (IBAction)pushFacebook:(UIButton *)sender;
- (IBAction)pushTwitter:(UIButton *)sender;
@property ACAccount *facebookAccount;
@property ACAccount *twitterAccounts;

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

//Facebookアカウント取得処理
- (IBAction)pushFacebook:(UIButton *)sender {
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"ログイン中です" maskType:SVProgressHUDMaskTypeGradient];
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ ACFacebookAppIdKey : @"673123156062598",
                               ACFacebookAudienceKey : ACFacebookAudienceFriends,
                               ACFacebookPermissionsKey : @[@"email"] };
    
    [_accountStore requestAccessToAccountsWithType:accountType
                                           options:options
                                        completion:^(BOOL granted, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (granted) {
                                                    
                                                    NSArray *arrayOfAccounts = [_accountStore
                                                                                accountsWithAccountType:accountType];
                                                    
                                                    if([arrayOfAccounts count] == 0){
                                                        //Twitterアカウント設定が1つもない場合の処理
                                                        NSLog(@"Facebookアカウントが登録されていません");
                                                        [SVProgressHUD dismiss];
                                                        //アラート出す
                                                        UIAlertView *alert =
                                                        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"Facebookアカウントが登録されていません。設定→Facebook→アカウントの使用許可する→Gocciをオンにする必要があります。"
                                                                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                                                        [alert show];
                                                        
                                                    }else if([arrayOfAccounts count] > 1){
                                                        //複数アカウント設定がある場合
                                                        NSMutableArray *facebookAccounts = [[NSMutableArray alloc] init];
                                                        facebookAccounts = [[_accountStore accountsWithAccountType:accountType] mutableCopy];
                                                        
                                                        for (int i = 0; i < [facebookAccounts count]; i++) {
                                                            //ここで取得
                                                            ACAccount *fbAccount = [facebookAccounts objectAtIndex:i];
                                                            NSLog(@"facebookAccount:%@",fbAccount);
                                                           
                                                            NSString *email = [[fbAccount valueForKey:@"properties"]  objectForKey:@"ACUIDisplayUsername"];
                                                            NSString *fullname = [[fbAccount valueForKey:@"properties"]  objectForKey:@"ACPropertyFullName"];
                                                            NSLog(@"fullname:%@",fullname);
                                                            AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
                                                            logindelegate.username = fullname;
                                                            NSString *uid = [[fbAccount valueForKey:@"properties"] objectForKey:@"uid"];
                                                            NSLog(@"uid:%@",uid);
                                                            NSString *pictureURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", uid];
                                                            NSLog(@"pictureURL%@", pictureURL); // プロフィール写真
                                                            AppDelegate* picturedelegate = [[UIApplication sharedApplication] delegate];
                                                            picturedelegate.userpicture = pictureURL;
                                                            NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",fullname,pictureURL];
                                                            NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/login/"];
                                                            NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
                                                            [urlRequest setHTTPMethod:@"POST"];
                                                            [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
                                                            NSURLResponse* response;
                                                            NSError* error = nil;
                                                            NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                                                                   returningResponse:&response
                                                                                                               error:&error];
                                                            NSLog(@"result:%@",result);
                                                            
                                                            [self performSegueWithIdentifier:@"goTimeline" sender:self];
                                                            NSLog(@"FacebookLogin is completed");
                                                        }
                                                    }else{
                                                        //Twitterアカウントが1つだけの場合
                                                        ACAccount *account = [[_accountStore accountsWithAccountType:accountType] lastObject];
                                                        NSLog(@"facebookAccount:%@",account);
                                                        
                                                        NSString *email = [[account valueForKey:@"properties"]  objectForKey:@"ACUIDisplayUsername"];
                                                        NSLog(@"email:%@",email);
                                                        NSString *fullname = [[account valueForKey:@"properties"]  objectForKey:@"ACPropertyFullName"];
                                                        AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
                                                        logindelegate.username = fullname;
                                                        NSLog(@"fullname:%@",fullname);
                                                        NSString *uid = [[account valueForKey:@"properties"] objectForKey:@"uid"];
                                                        NSLog(@"uid:%@",uid);
                                                        NSString *pictureURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", uid];
                                                        NSLog(@"pictureURL%@", pictureURL); // プロフィール写真
                                                        AppDelegate* picturedelegate = [[UIApplication sharedApplication] delegate];
                                                        picturedelegate.userpicture = pictureURL;
                                                        NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",fullname,pictureURL];
                                                        NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/login/"];
                                                        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
                                                        [urlRequest setHTTPMethod:@"POST"];
                                                        [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
                                                        NSURLResponse* response;
                                                        NSError* error = nil;
                                                        NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                                                               returningResponse:&response
                                                                                                           error:&error];
                                                        NSLog(@"result:%@",result);
                                                        
                                                        [self performSegueWithIdentifier:@"goTimeline" sender:self];
                                                        NSLog(@"FacebookLogin is completed");
                                                    }
                                                } else {
                                                    //データが取得できない場合
                                                    NSLog(@"No Facebook Access Error");
                                                    //アラート出す
                                                    UIAlertView *alert =
                                                    [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ログインが失敗しました。Facebookアカウントを持っているか確認してください。"
                                                     
                                                                              delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                                                    [alert show];
                                                    [SVProgressHUD dismiss];
                                                }
                                            });
                                        }];
    
}


//Twitterアカウント取得処理
- (IBAction)pushTwitter:(UIButton *)sender// Create an account store object.
{
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"ログイン中です" maskType:SVProgressHUDMaskTypeGradient];
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [_accountStore requestAccessToAccountsWithType:accountType
                                          options:NULL
                                       completion:^(BOOL granted, NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (granted) {
                                                   
                                                   NSArray *arrayOfAccounts = [_accountStore
                                                                               accountsWithAccountType:accountType];
                                                   
                                                   if([arrayOfAccounts count] == 0){
                                                       //Twitterアカウント設定が1つもない場合の処理
                                                       NSLog(@"Twitterアカウントが登録されていません");
                                                       [SVProgressHUD dismiss];
                                                       //アラート出す
                                                       UIAlertView *alert =
                                                       [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"Twitterアカウントが登録されていません。設定→Twitter→アカウントの使用許可する→Gocciをオンにする必要があります。"
                                                                                 delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                                                       [alert show];

                                                   }else if([arrayOfAccounts count] > 1){
                                                       //複数アカウント設定がある場合
                                                       NSMutableArray *twitterAccounts = [[NSMutableArray alloc] init];
                                                       twitterAccounts = [[_accountStore accountsWithAccountType:accountType] mutableCopy];
                                                       
                                                       for (int i = 0; i < [twitterAccounts count]; i++) {
                                                           //ここで取得
                                                           ACAccount *twAccount = [twitterAccounts objectAtIndex:i];
                                                          NSLog(@"twitterAccount:%@",twAccount);
                                                           NSString *twitterusername = [twAccount valueForKey:@"username"];
                                                           NSLog(@"fullname:%@",twitterusername);
                                                           AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
                                                           logindelegate.username = twitterusername;
                                                           NSString *twitteruid = [[twAccount valueForKey:@"properties"] objectForKey:@"user_id"];
                                                           NSLog(@"uid:%@",twitteruid);
                                                           NSString *pictureURL = [[NSString alloc] initWithFormat:@"http://www.paper-glasses.com/api/twipi/%@", twitterusername];
                                                           AppDelegate* picturedelegate = [[UIApplication sharedApplication] delegate];
                                                           picturedelegate.userpicture = pictureURL;
                                                           NSLog(@"%@",pictureURL);
                                                           NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",twitterusername,pictureURL];
                                                           NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/login/"];
                                                           NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
                                                           [urlRequest setHTTPMethod:@"POST"];
                                                           [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
                                                           NSURLResponse* response;
                                                           NSError* error = nil;
                                                           NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                                                                  returningResponse:&response
                                                                                                              error:&error];
                                                           NSLog(@"result:%@",result);
                                                           [self performSegueWithIdentifier:@"goTimeline2" sender:self];
                                                           NSLog(@"TwitterLogin is completed");
                                
                                                       }
                                                   }else{
                                                       //Twitterアカウントが1つだけの場合
                                                       ACAccount *account = [[_accountStore accountsWithAccountType:accountType] lastObject];
                                                       NSLog(@"twitterAccount:%@",account);
                                                       NSString *twitterusername = [account valueForKey:@"username"];
                                                       NSLog(@"fullname:%@",twitterusername);
                                                       AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
                                                       logindelegate.username = twitterusername;
                                                       NSString *twitteruid = [[account valueForKey:@"properties"] objectForKey:@"user_id"];
                                                       NSLog(@"uid:%@",twitteruid);
                                                       NSString *pictureURL = [[NSString alloc] initWithFormat:@"http://www.paper-glasses.com/api/twipi/%@", twitterusername];
                                                       NSLog(@"%@",pictureURL);
                                                       AppDelegate* picturedelegate = [[UIApplication sharedApplication] delegate];
                                                       picturedelegate.userpicture = pictureURL;
                                                       NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",twitterusername,pictureURL];
                                                       NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/login/"];
                                                       NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
                                                       [urlRequest setHTTPMethod:@"POST"];
                                                       [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
                                                       NSURLResponse* response;
                                                       NSError* error = nil;
                                                       NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                                                              returningResponse:&response
                                                                                                          error:&error];
                                                       NSLog(@"result:%@",result);
                                                       [self performSegueWithIdentifier:@"goTimeline2" sender:self];
                                                       NSLog(@"TwitterLogin is completed");

                                                   }
                                               } else {
                                                   //データが取得できない場合
                                                   NSLog(@"No Twitter Access Error");
                                                   //アラート出す
                                                   UIAlertView *alert =
                                                   [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ログインが失敗しました。Twitterアカウントを持っているか確認してください。"
                                                                             delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                                                   
                                                   [alert show];
                                                   [SVProgressHUD dismiss];
                                               }
                                           });
                                       }];
}



@end