//
//  DummyViewController.m
//  Gocci
//
//  Created by デザミ on 2015/05/10.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "DummyViewController.h"

@interface DummyViewController ()

@end

@implementation DummyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
	// NavigationBar 表示
	[self.navigationController setNavigationBarHidden:NO animated:NO];

	
	[super viewWillAppear:animated];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
