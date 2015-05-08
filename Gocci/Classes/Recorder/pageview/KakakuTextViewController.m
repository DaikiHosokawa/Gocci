//
//  KakakuTextViewController.m
//  Gocci
//
//  Created by デザミ on 2015/05/07.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "KakakuTextViewController.h"

#import "SCRecorderViewController.h"


@interface KakakuTextViewController ()
{
	__weak IBOutlet UITextField *textfieldKakaku;
	
}

@end

@implementation KakakuTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	//ナビゲーションバーに画像
	{
		//タイトル画像設定
		UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
		UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		navigationTitle.image = image;
		self.navigationItem.titleView =navigationTitle;
	}

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
	
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

- (IBAction)onOkey:(id)sender {

	//SCRecorderViewControllerに送信→SCSecondViewに送信
	static NSString * const namebundle = @"screcorder";
	
	SCRecorderViewController* viewController = nil;
	{
		CGRect rect = [UIScreen mainScreen].bounds;
		if (rect.size.height == 480) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil];
			//ビューコントローラ取得
			viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
			//rootViewController = [storyboard instantiateInitialViewController];
		}
		else if (rect.size.height == 667) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil];
			//ビューコントローラ取得
			viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
			//rootViewController = [storyboard instantiateInitialViewController];
		}
		else if (rect.size.height == 736) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil];
			//ビューコントローラ取得
			viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
			//rootViewController = [storyboard instantiateInitialViewController];
		}
		else {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			//ビューコントローラ取得
			viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
			//rootViewController = [storyboard instantiateInitialViewController];
		}
	}
	[viewController sendKakakuValue:[textfieldKakaku.text intValue]];
	
	[self dismissViewControllerAnimated:YES completion:^{

	}];
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
