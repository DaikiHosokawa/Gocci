//
//  RegistView.m
//  Gocci
//
//  Created by ArzenalZkull on 3/13/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#import "RegistView.h"
#import "AppDelegate.h"
#import "BFPaperCheckbox.h"

@interface RegistView()
<BFPaperCheckboxDelegate>

@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox1;

@property (nonatomic, copy) NSArray *checkboxes;

@end

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
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

@implementation RegistView


#pragma mark - InitComponent 

-(void) initComponent {
    _tfEmail.layer.borderColor = Rgb2UIColor(240, 240, 240).CGColor;
    _tfEmail.layer.borderWidth = 1;
    _tfPwd.layer.borderColor = Rgb2UIColor(240, 240, 240).CGColor;
    _tfPwd.layer.borderWidth = 1;
    _tfUsername.layer.borderColor = Rgb2UIColor(240, 240, 240).CGColor;
    _tfUsername.layer.borderWidth = 1;
    
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.9f;
    self.layer.shadowRadius = 4.0;
    self.layer.cornerRadius = 4;
    
    _checkboxes = @[_checkbox1];
    
    for (NSUInteger i=0; i<[_checkboxes count]; i++) {
        BFPaperCheckbox *checkbox = _checkboxes[i];
        //selfに設定
        checkbox.delegate = self;
        checkbox.tag = (i+1);
        checkbox.layer.cornerRadius = 0.0;
    }

    
    _tfEmail.delegate = self;
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
    switch (dele.screenType) {
        case 2:  //for 3.5inch
        {
            if (textField == _tfUsername) {
                frame.origin.y = -100;
                self.frame =frame;
            } else if (textField == _tfEmail) {
                frame.origin.y = -140;
                self.frame =frame;
            } else if (textField == _tfPwd) {
                frame.origin.y = -180;
                self.frame =frame;
            }
        }
            break;
            
        case 3: //for 4.7inch
        {
            if (textField == _tfUsername) {
                frame.origin.y = -60;
                self.frame =frame;
            } else if (textField == _tfEmail) {
                frame.origin.y = -100;
                self.frame =frame;
            } else if (textField == _tfPwd) {
                frame.origin.y = -140;
                self.frame =frame;
            }
        }
            break;
            
        case 4: //for 5.5 inch
        {
            if (textField == _tfUsername) {
                frame.origin.y = -40;
                self.frame =frame;
            } else if (textField == _tfEmail) {
                frame.origin.y = -80;
                self.frame =frame;
            } else if (textField == _tfPwd) {
                frame.origin.y = -120;
                self.frame =frame;
            }
        }
            break;
            
        default: {
            if (textField == _tfUsername) {
                frame.origin.y = -80;
                self.frame =frame;
            } else if (textField == _tfEmail) {
                frame.origin.y = -120;
                self.frame =frame;
            } else if (textField == _tfPwd) {
                frame.origin.y = -160;
                self.frame =frame;
            }
        }
            break;
    }
    
    
    
    return YES;
}

#pragma mark - BGPaperCheckboxDelegate

- (void)paperCheckboxChangedState:(BFPaperCheckbox *)changedCheckbox
{
    if (!changedCheckbox.isChecked) {
        return;
    }
    
    for (BFPaperCheckbox *checkbox in self.checkboxes) {
        if (changedCheckbox != checkbox) {
            [checkbox uncheckAnimated:YES];
            continue;
        }
        
        // TODO: チェックボックス選択時の処理
        LOG(@"%@番目のチェックボックスを選択", @(changedCheckbox.tag));
    }
}


#pragma mark - Private Methods

/**
 *  チェックボックスのどれか1つが選択されているか
 *
 *  @return
 */
- (BOOL)_validateCheckboxes
{
    for (BFPaperCheckbox *checkbox in self.checkboxes) {
        if (checkbox.isChecked) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Functions
-(void) dismissKeyboard:(UITapGestureRecognizer *)tap {
    [_tfEmail resignFirstResponder];
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
    
    [SVProgressHUD show];
    
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
                NSString *alertMessage = @"Twitterのアカウントでサインインできません。";
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show];

                
                [SVProgressHUD dismiss];
                
                NSLog(@"ERROR, %@", [error localizedDescription]);
                
            }];
            
        } errorBlock:^(NSError *error) {
            
            NSString *alertMessage = @"Twitterのアカウントでサインインできません。";
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show];
            
            [SVProgressHUD dismiss];

            NSLog(@"ERROR");
            //exit(1);
            
        }];
        
    } errorBlock:^(NSError *error) {
        NSString *alertMessage = @"Twitterのアカウントでサインインできません。";
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alrt show];
        
        [SVProgressHUD dismiss];


        NSLog(@"ERROR");
        //exit(1);
        
    }];
}

-(IBAction)btnClose_clicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kActiveCancel object:nil];
    [self removeFromSuperview];
}

-(IBAction)btnFacebook_clicked:(id)sender {
   
    if (![self _validateCheckboxes]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"利用規約に同意してください"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    //_btnFacebook.hidden = YES;
    
    [SVProgressHUD show];
    
    // FBSessionLoginBehaviorForcingWebView
    FBSessionLoginBehavior loginBehavior = FBSessionLoginBehaviorWithFallbackToWebView;
    
    NSArray *permissionArray = @[@"user_about_me"];
    
    FBSession *session = [[FBSession alloc] initWithPermissions:permissionArray];
    
    [FBSession setActiveSession:session];
    
    [[FBSession activeSession] openWithBehavior:loginBehavior completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        
        if (error) {
            NSLog(@"FB Error: %@", error.localizedDescription);
            
            NSString *alertMessage = @"facebookのアカウントでサインインできません。";
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show];
            
        } else {
            
            [self updateForSessionChange];
        }
        
    }];
}

-(IBAction)btnTwitter_clicked:(id)sender {
    
    if (![self _validateCheckboxes]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"利用規約に同意してください"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    [self loginWithiOSAction:nil];
    //    [self reverseAuthAction:nil];
    
}

-(IBAction)btnRegistLocal_clicked:(id)sender {
    
    if (![self _validateCheckboxes]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"利用規約に同意してください"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    [SVProgressHUD show];
    
    [APIClient registUserWithUsername:_tfUsername.text
                         withPassword:_tfPwd.text
                            withEmail:_tfEmail.text
                              handler:^(id result, NSUInteger code, NSError *error) {
        [SVProgressHUD dismiss];
        //receive data
        if (!error) {
            NSLog(@"register user: %@", result);
            if ([result[@"code"] integerValue] == 200) {
                //success
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:@"成功です。サインインしてください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show];
                [[NSNotificationCenter defaultCenter] postNotificationName:kActiveCancel object:self];
                [self removeFromSuperview];
            } else {
                //fail
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:@"失敗です。再度アカウント作成をお願いします。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show];
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
       [SVProgressHUD show];
    
    // Login user with facebook info
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(backgroundQueue, ^{
        //save data and login
        [SVProgressHUD dismiss];
        [[NSNotificationCenter defaultCenter] postNotificationName:kActiveLogin object:self];
        [self removeFromSuperview];
    });
    
}

- (IBAction)tap_link:(id)sender {
    NSString *urlString = @"http://inase-inc.jp/rules/";
    NSURL *url= [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
    
}
@end
