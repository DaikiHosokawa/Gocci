//
//  submitViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "submitViewController.h"

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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitTwitter:(UIButton*)sender {
        [self postMedia:SLServiceTypeTwitter];
    }

- (IBAction)submitFacebook:(UIButton *)sender {
        [self postMedia:SLServiceTypeFacebook];
    }
    
-(void) postMedia:(NSString*)type
{
        NSString *serviceType = type;
        //if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        
        SLComposeViewController *viewController = [SLComposeViewController
                                                   composeViewControllerForServiceType:serviceType];
        [viewController setInitialText:@"アプリからの投稿"];
        
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
        //}
        
    }

@end
