//
//  TabbarBaseViewController.m
//  Gocci
//
//  Created by INASe on 2015/02/02.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "TabbarBaseViewController.h"

@interface TabbarBaseViewController ()

@end

@implementation TabbarBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = 40;
    tabFrame.origin.y = self.view.frame.size.height - 40;
    self.tabBar.frame = tabFrame;
    [self.tabBar setFrame:CGRectMake(self.tabBar.frame.origin.x,self.view.frame.size.height-40,self.tabBar.frame.size.width,40)];
    [self.view setBounds:self.tabBar.bounds];
    tabBarheight = 40;
*/
     // Do any additional setup after loading the view.
	
//	// !!!:dezamisystem・タブバー設定
//	{
//		UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
//		//タブ選択時のフォントとカラー
//		UIColor *colorSelected = [UIColor colorWithRed:0.9607843137254902 green:0.16862745098039217 blue:0.00 alpha:1.0];
//		NSDictionary *selectedAttributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : colorSelected};
//		[[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
//		//通常時のフォントとカラー
//		UIColor *colorNormal = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
//		NSDictionary *attributesNormal = @{NSFontAttributeName : font, NSForegroundColorAttributeName : colorNormal};
//		[[UITabBarItem appearance] setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
//		
//		//背景色
//		[UITabBar appearance].barTintColor = [UIColor whiteColor];
//	}
    
    {
        		UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
        		//タブ選択時のフォントとカラー
        		UIColor *colorSelected = [UIColor colorWithRed:0.9607843137254902 green:0.16862745098039217 blue:0.00 alpha:1.0];
        		NSDictionary *selectedAttributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : colorSelected};
        		[[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        	//通常時のフォントとカラー
        		UIColor *colorNormal = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        		NSDictionary *attributesNormal = @{NSFontAttributeName : font, NSForegroundColorAttributeName : colorNormal};
        		[[UITabBarItem appearance] setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
        
        		//背景色
        		[UITabBar appearance].barTintColor = [UIColor whiteColor];
        	}

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
	
	[super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated{
  [self createRaisedCenterButton];
    //背景色
    
}

- (void)createRaisedCenterButton {
    
    // Load Image
    UIImage *buttonImage = [UIImage imageNamed:@"rec_1"];
    UIImage *highlightImage = [UIImage imageNamed:@"rec_1"];
    
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
    
   // button.center = self.tabBar.center;
   /*
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height-9;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    */
    
    [button addTarget:self action:@selector(countup:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    //if (heightDifference)
        
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



    /*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controll
 er using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
