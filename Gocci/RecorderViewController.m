//
//  RecorderViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/23.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "RecorderViewController.h"
#import "KZCameraView.h"


@interface RecorderViewController ()

@property (nonatomic, strong) KZCameraView *cam;

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
    
    //Create CameraView
	self.cam = [[KZCameraView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 64.0) withVideoPreviewFrame:CGRectMake(0.0, 0.0, 320.0, 320.0)];
    self.cam.maxDuration = 6.0;
    self.cam.showCameraSwitch = YES; //Say YES to button to switch between front and back cameras
    //Create "save" button
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveVideo:)];
    
    [self.view addSubview:self.cam];
}

-(IBAction)saveVideo:(id)sender
{
    [self.cam saveVideoWithCompletionBlock:^(BOOL success) {
        if (success)
        {
            NSLog(@"WILL PUSH NEW CONTROLLER HERE");
            [self performSegueWithIdentifier:@"SavedVideoPush" sender:sender];
        }
    }];
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

@end
