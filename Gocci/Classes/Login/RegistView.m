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
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

@interface RegistView()
<BFPaperCheckboxDelegate>

@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox1;

@property (nonatomic, copy) NSArray *checkboxes;

@end

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
//#define kActiveLogin @"ActiveLogin"
#define KEY_EMAIL          @"KEYCHAIN_EMAIL"
#define KEY_FIRSTNAME      @"KEYCHAIN_FIRSTNAME"
#define KEY_LASTNAME       @"KEYCHAIN_LASTNAME"
#define KEY_FACEBOOKID     @"KEYCHAIN_FACEBOOKID"
#define KEY_FULLNAME       @"KEYCHAIN_FULLNAME"
#define KEY_GENDER         @"KEYCHAIN_GENDER"
#define kActiveCancel @"kActiveCancel"
#define kActiveLogin @"kActiveLogin"
#define kTwitterConsumerKey @"BjIi16n6oTTQosw7V8EekVOnY"
#define kTwitterConsumerSecret @"vczV03jB7lFFWcCWpFpb0WOFHFnPB6umJQeMOgxnllmXUKGEBj"

@implementation RegistView


#pragma mark - InitComponent

-(void) initComponent {
    /*
     _tfEmail.layer.borderColor = Rgb2UIColor(240, 240, 240).CGColor;
     _tfEmail.layer.borderWidth = 1;
     
     _tfPwd.layer.borderColor = Rgb2UIColor(240, 240, 240).CGColor;
     _tfPwd.layer.borderWidth = 1;
     */
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
    
    
    // _tfEmail.delegate = self;
    //_tfPwd.delegate = self;
    _tfUsername.delegate = self;
    
    //_btnFacebook.layer.cornerRadius = 5;
    //_btnTwitter.layer.cornerRadius = 5;
    _btnRegist.layer.cornerRadius = 5;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self addGestureRecognizer:tap];
    
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
            }
            /*
             else if (textField == _tfEmail) {
             frame.origin.y = -140;
             self.frame =frame;
             } else if (textField == _tfPwd) {
             frame.origin.y = -180;
             self.frame =frame;
             }
             */
        }
            break;
            
        case 3: //for 4.7inch
        {
            if (textField == _tfUsername) {
                frame.origin.y = -60;
                self.frame =frame;
            }
            /*
             else if (textField == _tfEmail) {
             frame.origin.y = -100;
             self.frame =frame;
             } else if (textField == _tfPwd) {
             frame.origin.y = -140;
             self.frame =frame;
             }
             */
        }
            break;
            
        case 4: //for 5.5 inch
        {
            if (textField == _tfUsername) {
                frame.origin.y = -40;
                self.frame =frame;
            }
            /*
             else if (textField == _tfEmail) {
             frame.origin.y = -80;
             self.frame =frame;
             } else if (textField == _tfPwd) {
             frame.origin.y = -120;
             self.frame =frame;
             }
             */
        }
            break;
            
        default: {
            if (textField == _tfUsername) {
                frame.origin.y = -80;
                self.frame =frame;
            }
            /*
             else if (textField == _tfEmail) {
             frame.origin.y = -120;
             self.frame =frame;
             } else if (textField == _tfPwd) {
             frame.origin.y = -160;
             self.frame =frame;
             }
             */
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
    //[_tfEmail resignFirstResponder];
    //[_tfPwd resignFirstResponder];
    [_tfUsername resignFirstResponder];
    CGRect frame = self.frame;
    frame.origin.y = 20;
    self.frame =frame;
}

-(IBAction)btnClose_clicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kActiveCancel object:nil];
    [self removeFromSuperview];
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
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *os = [@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion];
    NSLog(@"register_id:%@",[ud stringForKey:@"STRING"]);
    
    [APIClient Signup:_tfUsername.text os:os model:[UIDevice currentDevice].model register_id:[ud stringForKey:@"STRING"] handler:^(id result, NSUInteger code, NSError *error)
     {
         [SVProgressHUD dismiss];
         //receive data
         NSLog(@"register result: %@ error :%@", result, error);
         if (!error) {
             NSLog(@"register user: %@", result);
             if ([result[@"code"] integerValue] == 200) {
                 
                 NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
                 [def setObject:result[@"username"] forKey:@"username"];
                 [def setObject:result[@"identity_id"] forKey:@"identity_id"];
                 [def setObject:result[@"token"] forKey:@"token"];
            
                 AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                                       initWithRegionType:AWSRegionUSEast1
                                                                       identityPoolId:@"us-east-1:2ef43520-856b-4641-b4a1-e08dfc07f802"];
                 
                 AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:credentialsProvider];
                 
                 [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                 
                 credentialsProvider.logins = @{ @"test.login.gocci": [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] };
                 
                 [[credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {
                     // Your handler code heredentialsProvider.identityId;
                     NSLog(@"logins: %@", credentialsProvider.logins);
                     // return [self refresh];
                     return nil;
                 }];
                 

    
                 [[NSNotificationCenter defaultCenter] postNotificationName:kActiveLogin object:self];
                 [self removeFromSuperview];
                 
             }else if([result[@"code"] integerValue] != 200) {
                 
                 //success
                 UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:@"このユーザー名はすでに使われております" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alrt show];
                 //[self removeFromSuperview];
                 
                 
             }
             else {
                 //fail
                 UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:result[@"message"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alrt show];
             }
         }
         
     }];
}



- (IBAction)tap_link:(id)sender {
    
    self.ruleView.hidden = NO;
    
    self.ruleWebView.delegate = self;
    self.ruleWebView.scalesPageToFit = YES;
    [self.ruleView addSubview:self.ruleWebView];
    
    NSURL *url = [NSURL URLWithString:@"http://inase-inc.jp/rules/"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.ruleWebView loadRequest:req];
    
    // 画像を指定したボタン例文
    UIImage *img = [UIImage imageNamed:@"btn_delete_white.png"];  // ボタンにする画像を生成する
    [self.ruleCancel setBackgroundImage:img forState:UIControlStateNormal];  // 画像をセットする
    // ボタンが押された時にhogeメソッドを呼び出す
    [self.ruleCancel addTarget:self
                        action:@selector(hoge:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)hoge:(UIButton*)button{
    self.ruleView.hidden = YES;
}



@end
