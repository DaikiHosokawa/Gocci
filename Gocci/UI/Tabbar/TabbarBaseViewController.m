//
//  TabbarBaseViewController.m
//  Gocci
//
//  Created by INASE on 2015/02/02.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "TabbarBaseViewController.h"

@interface TabbarBaseViewController ()

@end

@implementation TabbarBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
  [self createRaisedCenterButton];
}

- (void)createRaisedCenterButton {
    
    UIImage *buttonImage = [UIImage imageNamed:@"rec_1"];
    UIImage *highlightImage = [UIImage imageNamed:@"rec_1_sel"];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(countup:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
        
}

-(void)countup:(id)inSender{
 [self performSegueWithIdentifier:@"go_Rec1" sender:self];
}


- (IBAction)afterRecording:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"afterRecording"]) {
        NSLog(@"afterRecording success");
    }
}



@end
