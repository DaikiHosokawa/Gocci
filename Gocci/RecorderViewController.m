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

@interface RecorderViewController ()

@property (weak, nonatomic) IBOutlet UIView *subView;

@end

@implementation RecorderViewController


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
    _cam = [[KZCameraView alloc]initWithFrame:self.view.frame withVideoPreviewFrame:CGRectMake(0.0, 0.0, 320.0, 320.0)];
    [self.view addSubview:_cam];
    _cam.maxDuration = 6.0;
    _cam.showCameraSwitch = YES;
    
    //背景にイメージを追加したい
    UIImage *backgroundImage = [UIImage imageNamed:@"login.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.subView.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.6];

    
    //Saveボタンの設置
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完了" style:UIBarButtonItemStyleBordered target:self action:@selector(saveVideo:)];

}

//ナビゲーションバーのSavaボタンを押した時の動作
-(IBAction)saveVideo:(id)sender
{
    [_cam saveVideoWithCompletionBlock:^(BOOL success) {
        if (success)
        {
            NSLog(@"WILL PUSH NEW CONTROLLER HERE");
        
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
