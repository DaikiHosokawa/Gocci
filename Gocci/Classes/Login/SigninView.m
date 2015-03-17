//
//  SigninView.m
//  Gocci
//
//  Created by Le Anh Tuan on 3/14/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#import "SigninView.h"
#import "AppDelegate.h"

#define kActiveLogin @"ActiveLogin"
#define KEY_EMAIL          @"KEYCHAIN_EMAIL"
#define KEY_FIRSTNAME      @"KEYCHAIN_FIRSTNAME"
#define KEY_LASTNAME       @"KEYCHAIN_LASTNAME"
#define KEY_FACEBOOKID     @"KEYCHAIN_FACEBOOKID"
#define KEY_FULLNAME       @"KEYCHAIN_FULLNAME"
#define KEY_GENDER         @"KEYCHAIN_GENDER"
#define kActiveCancel @"kActiveCancel"
#define kTwitterConsumerKey @"BjIi16n6oTTQosw7V8EekVOnY"
#define kTwitterConsumerSecret @"vczV03jB7lFFWcCWpFpb0WOFHFnPB6umJQeMOgxnllmXUKGEBj"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@implementation SigninView 

-(void) initComponent {
    _tfPwd.layer.borderColor = Rgb2UIColor(240, 240, 240).CGColor;
    _tfPwd.layer.borderWidth = 1;
    _tfUsername.layer.borderColor = Rgb2UIColor(240, 240, 240).CGColor;
    _tfUsername.layer.borderWidth = 1;
    
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.9f;
    self.layer.shadowRadius = 4.0;
    self.layer.cornerRadius = 4;
    
    _tfPwd.delegate = self;
    _tfUsername.delegate = self;
    
    _btnFacebook.layer.cornerRadius = 5;
    _btnTwitter.layer.cornerRadius = 5;
    _btnRegist.layer.cornerRadius = 5;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self addGestureRecognizer:tap];
    
    self.accountStore = [[ACAccountStore alloc] init];
    _consumerKeyTextField = kTwitterConsumerKey;
    _consumerSecretTextField = kTwitterConsumerSecret;
    
}



#pragma mark - UITextfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"Textfield begin edit");
    CGRect frame = self.frame;
    AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (dele.screenType == 3 || dele.screenType == 4) {
        return YES;
    }
    
    if (textField == _tfUsername) {
        frame.origin.y = -30;
        self.frame =frame;
    } else if (textField == _tfPwd) {
        frame.origin.y = -50;
        self.frame =frame;
    }
    
    return YES;
}


#pragma mark - Functions
-(void) dismissKeyboard:(UITapGestureRecognizer *)tap {
    [_tfPwd resignFirstResponder];
    [_tfUsername resignFirstResponder];
    CGRect frame = self.frame;
    frame.origin.y = 20;
    self.frame =frame;
}

- (void)updateForSessionChange
{
    if ([FBSession activeSession].isOpen) {
        // fetch profile info such as name, id, etc. for the open session
        FBRequest *me = [FBRequest requestForMe];
        
        [me startWithCompletionHandler:^(FBRequestConnection *connection,
                                         NSDictionary<FBGraphUser> *result,
                                         NSError *error) {
            
            // we interpret an error in the initial fetch as a reason to
            // fail the user switch, and leave the application without an
            // active user (similar to initial state)
            if (error) {
                NSLog(@"FB Error: %@", error.localizedDescription);
                
                NSString *alertMessage = @"facebookでアカウントでサインインできません。";
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show];
                
                return;
            }
            
            
            NSLog(@"FB accesstoken: %@", [FBSession activeSession].accessTokenData.accessToken);
            [self loginViewFetchedUserInfo:result];
            
        }];
    } else {
        // in the closed case, we check to see if we picked up a cached token that we
        // expect to be valid and ready for use; if so then we open the session on the spot
        if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [[FBSession activeSession] openWithCompletionHandler:^(FBSession *innerSession,
                                                                   FBSessionState status,
                                                                   NSError *error) {
                [self updateForSessionChange];
            }];
        }
        else {
            
            _btnFacebook.hidden = NO;
            [SVProgressHUD dismiss];
            
            NSString *alertMessage = @"facebookでアカウントでサインインできません。";
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show];
            
        }
    }
}



#pragma mark - IbActions

- (IBAction)loginWithiOSAction:(id)sender {
    
    NSLog(@"Trying to login with iOS...");
   [SVProgressHUD showWithStatus:@"ログイン中" maskType:SVProgressHUDMaskTypeAnimation];
    
    __weak typeof(self) weakSelf = self;
    
    self.accountChooserBlock = ^(ACAccount *account, NSString *errorMessage) {
        
        NSString *status = nil;
        if(account) {
            status = [NSString stringWithFormat:@"Did select %@", account.username];
            
            [weakSelf loginWithiOSAccount:account];
        } else {
            [SVProgressHUD dismiss];
            status = errorMessage;
        }
        
    };
    
    [self chooseAccount];
}

- (void)loginWithiOSAccount:(ACAccount *)account {
    
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        NSLog(@"Username: %@", username);
        
        [self reverseAuthAction:nil];
        
    } errorBlock:^(NSError *error) {
        NSLog([NSString stringWithFormat:@"%@", [error localizedDescription]]);
        [SVProgressHUD dismiss];
    }];
    
}

- (IBAction)reverseAuthAction:(id)sender {
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil consumerKey:_consumerKeyTextField consumerSecret:_consumerSecretTextField];
    [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        
        STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithFirstAccount];
        [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            
            
            [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader successBlock:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName) {
                
                [SVProgressHUD dismiss];
                
                NSLog(@"REVERSE AUTH screen %@ userID: %@", screenName, userID);
                
                NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
                [def setObject:screenName forKey:@"username"];
                [def setObject:@"" forKey:@"pwd"];
                [def setObject:@"twitter" forKey:@"type"];
                [def setObject:userID forKey:@"user_id"];
                [def setObject:@"" forKey:@"email"];
                NSString *pictureURL = [[NSString alloc] initWithFormat:@"http://www.paper-glasses.com/api/twipi/%@", screenName];
                [def setObject:pictureURL forKey:@"avatarLink"];
                [def synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:kActiveLogin object:self];

                
                
            } errorBlock:^(NSError *error) {
                
                [SVProgressHUD dismiss];
                
                NSLog(@"ERROR, %@", [error localizedDescription]);
                
            }];
            
        } errorBlock:^(NSError *error) {
            
            NSLog(@"ERROR");
            exit(1);
            
        }];
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"ERROR");
        exit(1);
        
    }];
}

-(IBAction)btnClose_clicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kActiveCancel object:nil];
    [self removeFromSuperview];
}


-(IBAction)btnFacebook_clicked:(id)sender {
    _btnFacebook.hidden = YES;
    //[SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"ログイン中" maskType:SVProgressHUDMaskTypeAnimation];
    // FBSessionLoginBehaviorForcingWebView
    FBSessionLoginBehavior loginBehavior = FBSessionLoginBehaviorWithFallbackToWebView;
    
    NSArray *permissionArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"publish_stream"];
    
    FBSession *session = [[FBSession alloc] initWithPermissions:permissionArray];
    
    [FBSession setActiveSession:session];
    
    [[FBSession activeSession] openWithBehavior:loginBehavior completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        
        if (error) {
            NSLog(@"FB Error: %@", error.localizedDescription);
            
            NSString *alertMessage = @"facebookでアカウントでサインインできません。";
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show];
            
        } else {
            
            [self updateForSessionChange];
        }
        
    }];
}

-(IBAction)btnTwitter_clicked:(id)sender {
    
    [self loginWithiOSAction:nil];
//    [self reverseAuthAction:nil];
    
}

-(IBAction)btnRegistLocal_clicked:(id)sender {
   // [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"ログイン中" maskType:SVProgressHUDMaskTypeAnimation];
    [APIClient loginUserWithUsername:_tfUsername.text withPassword:_tfPwd.text handler:^(id result, NSUInteger code, NSError *error) {
        //success
        [SVProgressHUD dismiss];
        //receive data
        if (!error) {
            NSLog(@"login user: %@", result);
            if ([result[@"code"] integerValue] == 200) {
                //success
                
                NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
                [def setObject:_tfUsername.text forKey:@"username"];
                [def setObject:_tfPwd.text forKey:@"pwd"];
                [def setObject:@"local" forKey:@"type"];
                [def setObject:@"" forKey:@"user_id"];
                [def setObject:@"" forKey:@"email"];
                [def setObject:result[@"picture"] forKey:@"avatarLink"];
                [def synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:kActiveLogin object:self];
                
               // UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:result[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                //[alrt show];
                [self removeFromSuperview];
            } else {
                //fail
                //UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:result[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
               // [alrt show];
            }
        }
        
    }];
    
}

- (void)chooseAccount {
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                _accountChooserBlock(nil, @"Acccess not granted.");
                return;
            }
            
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            
            if([_iOSAccounts count] == 1) {
                ACAccount *account = [_iOSAccounts lastObject];
                _accountChooserBlock(account, nil);
            } else {
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil otherButtonTitles:nil];
                for(ACAccount *account in _iOSAccounts) {
                    [as addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                }
            }
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
    
}


#pragma mark - FBLoginViewDelegate

- (void)loginViewFetchedUserInfo:(id<FBGraphUser>)user
{
    NSLog(@"%@", user);
    
    // Show indicator
    //8b353d5cc07e13577608711f4602fcb7@1407628801
    
    // Submit user info to server
    NSDictionary *params = @{
                             @"email" : user[@"email"],
                             @"name" : user[@"name"],
                             @"gender" : user[@"gender"],
                             @"first_name" : user[@"first_name"],
                             @"last_name" : user[@"last_name"],
                             @"id" : user[@"id"],
                             @"link" : user[@"link"],
                             @"locale" : user[@"locale"],
                             @"atk" : [FBSession activeSession].accessTokenData.accessToken
                             };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:user[@"name"] forKey:@"username"];
    [defaults setObject:[FBSession activeSession].accessTokenData.accessToken forKey:@"pwd"];
    [defaults setObject:@"facebook" forKey:@"type"];
    [defaults setObject:@"" forKey:@"user_id"];
    [defaults setObject:user[@"email"] forKey:@"email"];
    
    NSString *pictureURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", user[@"id"] ];
    [defaults setObject:pictureURL forKey:@"avatarLink"];
    
    [defaults synchronize];
    
    // Show activity while download film types
    [SVProgressHUD showWithStatus:@"ログイン中" maskType:SVProgressHUDMaskTypeAnimation];
    
    // Login user with facebook info
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(backgroundQueue, ^{
        //save data and login
        [SVProgressHUD dismiss];
        [[NSNotificationCenter defaultCenter] postNotificationName:kActiveLogin object:self];
        [self removeFromSuperview];
    });
    
}


@end
