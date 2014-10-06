//
//  RecorderViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/23.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "RecorderViewController.h"
#import "CaptureManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RestaurantTableViewController.h"

static const NSInteger firstAlertTag = 1;
static const NSInteger secondAlertTag = 2;
static const NSInteger thirdAlertTag = 3;

@interface RecorderViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *subView;

@end

@implementation RecorderViewController
@synthesize cam;

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
    
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive: NO error:&activationError];
    
    //カメラのスペース確保
    _cam = [[KZCameraView alloc]initWithFrame:self.view.frame withVideoPreviewFrame:CGRectMake(0.0, 0.0, 320.0, 320.0)];
    [self.view addSubview:_cam];
    _cam.maxDuration = 6.0;
    _cam.showCameraSwitch = YES;
    
    [RecorderViewController    isMicAccessEnableWithIsShowAlert:YES
                                    completion:
     ^(BOOL isMicAccessEnable) {
         // アクセス許可がある場合はisMicAccessEnableがYES
     }];
    
    /*
    //背景にイメージを追加したい
    UIImage *backgroundImage = [UIImage imageNamed:@"login.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.subView.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.9];
    */
    
    //Saveボタンの設置
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完了" style:UIBarButtonItemStyleBordered target:self action:@selector(saveVideo:)];

}

+ (void)isMicAccessEnableWithIsShowAlert:(BOOL)_isShowAlert
                              completion:(IsMicAccessEnableWithIsShowAlertBlock)_completion
{
    //    // メソッドの存在チェック。存在しない場合はiOS7未満なのでYESを返す なぜか動作しなかった
    //    if (![AVCaptureDevice instancesRespondToSelector:@selector(authorizationStatusForMediaType:)]) {
    //        return YES;
    //    }
    
    IsMicAccessEnableWithIsShowAlertBlock completion = [_completion copy];
    
    // iOS7.0未満
    NSString *iOsVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"iOsVersion = %@", iOsVersion);
    if ( [iOsVersion compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending ) {
        completion(YES);
        return;
    }
    
    // このアプリマイクへの認証状態を取得する
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (status) {
        case AVAuthorizationStatusAuthorized: // マイクへのアクセスが許可されている
            completion(YES);
            break;
        case AVAuthorizationStatusNotDetermined: // マイクへのアクセスを許可するか選択されていない
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                     completionHandler:
             ^(BOOL granted) {
                 // メインスレッド
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     if(granted){
                         //許可完了
                         completion(YES);
                     } else {
                         //許可されなかった
                         completion(NO);
                         
                        UIAlertView *firstAlert = [[UIAlertView alloc]
                                                   initWithTitle:@"エラー"
                                                   message:@"マイクへのアクセスが許可されていません。\n設定 > プライバシー > マイクで許可してください。"
                                                   delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                         firstAlert.tag = firstAlertTag;
                         [firstAlert show];
                         
                     }
                 });
             }];
            
        }
            break;
        case AVAuthorizationStatusRestricted: // 設定 > 一般 > 機能制限で利用が制限されている
        {
            if (_isShowAlert) {
               UIAlertView *secondAlert = [[UIAlertView alloc]
                                          initWithTitle:@"エラー"
                                          message:@"マイクへのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"
                                          delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                secondAlert.tag = secondAlertTag;
                [secondAlert show];
            }
            completion(NO);
        }
            break;
        case AVAuthorizationStatusDenied: // 設定 > プライバシー > で利用が制限されている
        {
            if (_isShowAlert) {
             UIAlertView  *thirdAlert = [[UIAlertView alloc]
                                          initWithTitle:@"エラー"
                                          message:@"マイクへのアクセスが許可されていません。\n設定 > プライバシー > マイクで許可してください。"
                                          delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                thirdAlert.tag = thirdAlertTag;
    
                
                       [thirdAlert show];
                
            }
            completion(NO);
        }
            break;
            
        default:
            break;
    }
}

//アラートのボタンが押されたときに呼ばれるデリゲーションメソッド
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //タグをチェック
    if (alertView.tag == firstAlertTag)  {
         NSLog(@"test");
    }else if (alertView.tag == secondAlertTag)  {
        NSLog(@"test2");
    }else if (alertView.tag == thirdAlertTag)  {
        NSLog(@"test3");
    }
}

//ナビゲーションバーのSaveボタンを押した時の動作
-(IBAction)saveVideo:(id)sender
{
    [_cam saveVideoWithCompletionBlock:^(BOOL success) {
        if (success)
        {
            NSLog(@"共有画面へ移動");
        
            [self performSegueWithIdentifier:@"SavedVideoPush" sender:sender];
            
        }
    }];
}


              
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
                  NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                  NSLog(@"%@", jsonObject);
              }
              
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
                  NSLog(@"%@", error);
              }



-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
}

@end
