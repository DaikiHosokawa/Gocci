//
//  everyBaseNavigationController.m
//  Gocci
//
//  Created by デザミ on 2015/02/09.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "everyBaseNavigationController.h"

@interface everyBaseNavigationController ()

@end

@implementation everyBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)rootViewController
{
	return [[self viewControllers] firstObject];
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
