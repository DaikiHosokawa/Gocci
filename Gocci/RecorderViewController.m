//
//  RecorderViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/23.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "RecorderViewController.h"
#import "KZCameraView.h"
#import "CaptureManager.h"

@interface RecorderViewController ()


@property (nonatomic, strong) KZCameraView *cam;

@end

@implementation RecorderViewController

- (id)init
{
    assetsLibrary_ = [[ALAssetsLibrary alloc] init];
    return self;
}

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
    
    //カメラのスペース確保
    self.cam = [[KZCameraView alloc]initWithFrame:self.view.frame withVideoPreviewFrame:CGRectMake(0.0, 0.0, 320.0, 320.0)];
    [self.view addSubview:self.cam];
    self.cam.maxDuration = 6.0;
    self.cam.showCameraSwitch = YES;
    
    
    //Saveボタンの設置
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveVideo:)];

}



//ナビゲーションバーのSaveボタンを押した時の動作
-(IBAction)saveVideo:(id)sender
{
    [self.cam saveVideoWithCompletionBlock:^(BOOL success) {
        if (success)
        {
            NSLog(@"WILL PUSH NEW CONTROLLER HERE");
            [self performSegueWithIdentifier:@"SavedVideoPush" sender:sender];
            
    
            NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"];
            NSData *sampleData = [NSData dataWithContentsOfFile:samplePath];
            
            //送信先URL
            NSURL *url = [NSURL URLWithString:@"http://codecamp1353.lesson2.codecamp.jp/sample.php"];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            NSLog(@"ポスト成功");
            
            //multipart/form-dataのバウンダリ文字列生成
            CFUUIDRef uuid = CFUUIDCreate(nil);
            CFStringRef uuidString = CFUUIDCreateString(nil, uuid);
            CFRelease(uuid);
            NSString *boundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
            
            //アップロードする際のパラメーター名
            NSString *parameter = @"movie";
            
            //アップロードするファイルの名前
            NSString *fileName = [[samplePath componentsSeparatedByString:@"/"] lastObject];
            
            //アップロードするファイルの種類
            NSString *contentType = @"video/mp4";
            
            NSMutableData *postBody = [NSMutableData data];
            
            //HTTPBody
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",parameter,fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:sampleData];
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            //リクエストヘッダー
            NSString *header = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            
            [request addValue:header forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postBody];
            
            
            [NSURLConnection connectionWithRequest:request delegate:self];
        }

        
    }];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	if(httpResponse.statusCode == 200) {
        
		NSLog(@"Success ٩꒰๑ ´∇`๑꒱۶✧");
        // アラートビューを作成
        // キャンセルボタンを表示しない場合はcancelButtonTitleにnilを指定
        UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"タイトル"
                                  message:@"成功"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Button1", @"Button2", nil];
        // アラートビューを表示
        [alert show];
        
	} else {
		
		NSLog(@"Failed (´;ω;`)");
        // アラートビューを作成
        // キャンセルボタンを表示しない場合はcancelButtonTitleにnilを指定
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"タイトル"
                              message:@"失敗"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Button1", @"Button2", nil];
        // アラートビューを表示
        [alert show];
    }
    
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end