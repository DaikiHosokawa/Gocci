//
//  submitViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "submitViewController.h"
#import "CaptureManager.h"

@interface submitViewController ()

- (IBAction)submitFacebook:(UIButton *)sender;
- (IBAction)submitTwitter:(UIButton *)sender;
@end

@implementation submitViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//Twitterの投稿
- (IBAction)submitTwitter:(UIButton*)sender {
        [self postMedia:SLServiceTypeTwitter];
    }

//Facebookの投稿
- (IBAction)submitFacebook:(UIButton *)sender {
        [self postMedia:SLServiceTypeFacebook];
    }
    
-(void) postMedia:(NSString*)type
{
        NSString *serviceType = type;
        //if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        
        SLComposeViewController *viewController = [SLComposeViewController
                                                   composeViewControllerForServiceType:serviceType];
    
        NSString* path = @"http://codecamp1353.lesson2.codecamp.jp/movies/mergeVideo-866.mp4";
        NSURL* url = [NSURL URLWithString:path];
        /*
        NSData* data = [NSData dataWithContentsOfURL:url];
         UIImage* img = [[UIImage alloc] initWithData:data];
         [viewController addImage:img];
       */
         [viewController setInitialText:@"グルメ動画アプリ「Gocci」からの投稿"];
        [viewController addURL:url]; //URLのセット
    
        viewController.completionHandler = ^(SLComposeViewControllerResult res) {
            if (res == SLComposeViewControllerResultCancelled) {
                NSLog(@"cancel");
            }
            else if (res == SLComposeViewControllerResultDone) {
                NSLog(@"done");
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        };
        [self presentViewController:viewController animated:YES completion:nil];
        
    }


@end
