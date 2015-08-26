//
//  TutorialPageView.m
//  Gocci
//

#import "TutorialPageView.h"
#import "TutorialView.h"
#import "APIClient.h"
#import "BFPaperCheckbox.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

@interface TutorialPageView()<UITextFieldDelegate,BFPaperCheckboxDelegate>

@property (nonatomic, weak) IBOutlet UIView *graphicView;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;

@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox1;

@property (nonatomic, copy) NSArray *checkboxes;

@end

@implementation TutorialPageView

+ (instancetype)viewWithNibName:(NSString *)nibName
{
    return [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
}

- (void)setup
{
    
    // 枠線のスタイルを設定
    _usernameField.borderStyle = UITextBorderStyleRoundedRect;
    
    // テキストを左寄せにする
    _usernameField.textAlignment = UITextAlignmentLeft;
    
    // ラベルのテキストのフォントを設定
    _usernameField.font = [UIFont fontWithName:@"Helvetica" size:14];
    
    // プレースホルダ
    _usernameField.placeholder = @"名前を入力してください";
    
    
    // キーボードの種類を設定
    _usernameField.keyboardType = UIKeyboardTypeDefault;
    
    // リターンキーの種類を設定
   _usernameField.returnKeyType = UIReturnKeyDefault;
    
    // 編集中にテキスト消去ボタンを表示
    _usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // デリゲートを設定
    _usernameField.delegate = self;
    
    /*
    _checkboxes = @[_checkbox1];
    
    for (NSUInteger i=0; i<[_checkboxes count]; i++) {
        BFPaperCheckbox *checkbox = _checkboxes[i];
        //selfに設定
        checkbox.delegate = self;
        checkbox.tag = (i+1);
        checkbox.layer.cornerRadius = 0.0;
    }
     */
    
}


/**
 * キーボードでReturnキーが押されたとき
 * @param textField イベントが発生したテキストフィールド
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"text:%@",_usernameField.text);
    // キーボードを隠す
    [self endEditing:YES];
    /*
    if (![self _validateCheckboxes]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"利用規約に同意してください"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
     */
    [self signup];
    
    return YES;
   
}


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
    
    [self signup];
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

-(void)signup{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *os = [@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion];
    NSLog(@"register_id:%@",[ud stringForKey:@"STRING"]);
    
    
    //execute Signup
    
    [APIClient Signup:_usernameField.text os:os model:[UIDevice currentDevice].model register_id:[ud stringForKey:@"STRING"] handler:^(id result, NSUInteger code, NSError *error)
     {
         //Log response data
         NSLog(@"register result: %@ error :%@", result, error);
         
         if (!error) {
             
             //not error & code = 200
             if ([result[@"code"] integerValue] == 200) {
                 
                 NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
                 [def setObject:result[@"username"] forKey:@"username"];
                 [def setObject:result[@"identity_id"] forKey:@"identity_id"];
                 [def setObject:result[@"token"] forKey:@"token"];
                 
                 AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                                 identityPoolId:@"us-east-1:b563cebf-1de2-4931-9f08-da7b4725ae35"];

                 AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
                 
                 [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                 
                 credentialsProvider.logins = @{ @"test.login.gocci": [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] };
                 
                 [[credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {
                     // Your handler code heredentialsProvider.identityId;
                     NSLog(@"task:%@",task);
                     return nil;
                 }];
                 
                 // 通知の受取側に送る値を作成する
                 NSDictionary *dic = [NSDictionary dictionaryWithObject:@"HOGE" forKey:@"KEY"];
                 
                 // 通知を作成する
                 NSNotification *n =
                 [NSNotification notificationWithName:@"Tuchi" object:self userInfo:dic];
                 
                 // 通知実行！
                 [[NSNotificationCenter defaultCenter] postNotification:n];

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




@end
