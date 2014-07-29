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
#import <AssetsLibrary/AssetsLibrary.h>
#import "R9HTTPRequest.h"

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
            
            NSURL *URL = [NSURL URLWithString:@"http://codecamp1353.lesson2.codecamp.jp/uploader.php"];
            R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:URL];
            [request setHTTPMethod:@"POST"];
            [request addBody:@"test" forKey:@"TestKey"];
            // create image
            UIImage *image = [UIImage imageNamed:@"logo.png"];
            //NSData *pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
            
            // Movie
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tester" ofType:@"mp4"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            
            // set image data
            [request setData:data withFileName:@"tester.mp4" andContentType:@"video/mp4" forKey:@"file"];
            [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
                NSLog(@"%@", responseString);
            }];
            // Progress
            [request setUploadProgressHandler:^(float newProgress){
                NSLog(@"%g", newProgress);
            }];
            [request startRequest];
            // Do any additional setup after loading the view, typically from a nib.
        }

        
    }];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	if(httpResponse.statusCode == 200) {
        
		NSLog(@"Success");
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
		
		NSLog(@"Failed");
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
