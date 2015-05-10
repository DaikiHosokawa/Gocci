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
	
	//ナビゲーションバーに画像
	{
		//タイトル画像設定
		UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
		UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		navigationTitle.image = image;
		self.navigationItem.titleView = navigationTitle;
		
		UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
		barButton.title = @"";
		self.navigationItem.backBarButtonItem = barButton;
	}

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
	// NavigationBar 非表示
	[self.navigationController setNavigationBarHidden:YES animated:NO];

	
	[super viewWillAppear:animated];
}

- (IBAction)onRecorder:(id)sender {

	//遷移：SCRecorderVideoController
	[self performSegueWithIdentifier:@"goRecorder" sender:self];
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
