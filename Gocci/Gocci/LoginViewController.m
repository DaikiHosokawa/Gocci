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
    NSArray *accounts = [_accountStore accountsWithAccountType:accountType];
    if (accounts.count == 0) {
        NSLog(@"Facebookアカウントが登録されていません");
         [SVProgressHUD dismiss];
        //アラート出す
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"Facebookアカウントが登録されていません"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];

        return;
    }
    NSDictionary *options = @{ ACFacebookAppIdKey : @"673123156062598",
                               ACFacebookAudienceKey : ACFacebookAudienceOnlyMe,
                               ACFacebookPermissionsKey : @[@"email"] };
    [_accountStore requestAccessToAccountsWithType:accountType
                                           options:options
                                        completion:^(BOOL granted, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (granted) {
                                                    [SVProgressHUD show];
                                                    [self authenticatePermissions];
                                                    _facebookAccount = [accounts objectAtIndex:0];
                                                    NSLog(@"facebookAccount:%@",_facebookAccount);
                                                    // _facebookAccount(ACAccountオブジェクト)
                                                    NSString *email = [[_facebookAccount valueForKey:@"properties"]  objectForKey:@"ACUIDisplayUsername"];
                                                    NSString *fullname = [[_facebookAccount valueForKey:@"properties"]  objectForKey:@"ACPropertyFullName"];
                                                    NSLog(@"fullname:%@",fullname);
                                                    NSString *uid = [[_facebookAccount valueForKey:@"properties"] objectForKey:@"uid"];
                                                    NSLog(@"uid:%@",uid);
                                                    NSString *pictureURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", uid];
                                                    NSLog(@"pictureURL%@", pictureURL); // プロフィール写真
                                                    
                                                    NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",fullname,pictureURL];
                                                    NSURL* url = [NSURL URLWithString:@"https://codelecture.com/gocci/signup.php"];
                                                    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
                                                    [urlRequest setHTTPMethod:@"POST"];
                                                    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
                                                    NSURLResponse* response;
                                                    NSError* error = nil;
                                                    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                                                           returningResponse:&response
                                                                                                       error:&error];
                                                
                                                    [self performSegueWithIdentifier:@"goTimeline" sender:self];
                                                    NSLog(@"FacebookLogin is completed");
                                                } else {
                                                    NSLog(@"User denied to access facebook account.");
                                                    UIAlertView *alert =
                                                    [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ログインが失敗しました"
                                                                              delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                                                    [alert show];
                                                }
                                            });
                                        }];
    
}

- (void)authenticatePermissions
{
    NSDictionary *options = @{ ACFacebookAppIdKey : @"673123156062598",
                               ACFacebookAudienceKey : ACFacebookAudienceOnlyMe,
                               // 本来指定したいpublish_streamパーミッションを指定。これで投稿可能になる。
                               ACFacebookPermissionsKey : /*@[@"publish_stream"]*/@[@"friends_birthday"]};
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [_accountStore requestAccessToAccountsWithType:accountType
                                           options:options
                                        completion:^(BOOL granted, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (granted) {
                                                    NSArray *accounts = [_accountStore accountsWithAccountType:accountType];
                                                    if (accounts.count > 0) {
                                                        _facebookAccount = [accounts objectAtIndex:0];
                                                        NSString *email = _facebookAccount.username;
                                                        NSString *fullname = [[_facebookAccount valueForKey:@"properties"] objectForKey:@"fullname"];
                                                        NSString *uid = [[_facebookAccount valueForKey:@"properties"] objectForKey:@"uid"];
                                                        NSString *pictureURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", uid];
                                                    } else {
                                                        NSLog(@"Not found user.");
                                                    }
                                                } else {
                                                    NSLog(@"User denied to access facebook account.");
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
    NSArray *accounts = [_accountStore accountsWithAccountType:accountType];
    if (accounts.count == 0) {
    NSLog(@"Twitterアカウントが登録されていません");
        [SVProgressHUD dismiss];
    //アラート出す
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"Twitterアカウントが登録されていません"
                              delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
    [alert show];
    
    return;
    }
    [_accountStore requestAccessToAccountsWithType:accountType options:nil
                                   completion:^(BOOL granted, NSError *error)
      {
        if (granted == YES)
        {
            NSArray *arrayOfAccounts = [_accountStore
                                        accountsWithAccountType:accountType];
            
            if ([arrayOfAccounts count] > 0)
            {
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                NSLog(@"twitterAccount:%@",twitterAccount);
                NSString *twitterusername = [twitterAccount valueForKey:@"username"];
                NSLog(@"fullname:%@",twitterusername);
                NSString *twitteruid = [[twitterAccount valueForKey:@"properties"] objectForKey:@"user_id"];
                NSLog(@"uid:%@",twitteruid);
                NSString *pictureURL = [[NSString alloc] initWithFormat:@"http://www.paper-glasses.com/api/twipi/%@", twitterusername];
                NSLog(@"%@",pictureURL);
                NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",twitterusername,pictureURL];
                NSURL* url = [NSURL URLWithString:@"https://codelecture.com/gocci/signup.php"];
                NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
                NSURLResponse* response;
                NSError* error = nil;
                NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                       returningResponse:&response
                                                                   error:&error];
                [self performSegueWithIdentifier:@"goTimeline2" sender:self];
                NSLog(@"TwitterLogin is completed");
            }
            else
            {
                NSLog(@"No Twitter Access Error");
                //アラート出す
                UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ログインが失敗しました"
                                          delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                [alert show];
            }
            
        }
    }];
}



@end