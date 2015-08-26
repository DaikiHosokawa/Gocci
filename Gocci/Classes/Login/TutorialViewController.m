//
//  TutorialViewController.m
//  Gocci
//
//  Created by Castela on 2015/08/25.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialView.h"
#import "TutorialPageView.h"

@interface TutorialViewController ()<TutorialViewDelegate>

@property (nonatomic, strong) TutorialView *tutorialView;

@end


@implementation TutorialViewController


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    NSLog(@"tutorial画面表示");
    
    self.tutorialView = [TutorialView showInView:self.view delegate:self];
    
}

-(void)viewDidAppear{
    [super viewDidAppear:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

#pragma mark - TutorialView Delegate

- (void)goSignin:(TutorialView *)view
{
    //ここにSigninへの遷移(1ページ目)
    [self.tutorialView dismiss];
}

- (void)goSNS:(TutorialView *)view
{
    NSLog(@"call goSNS method");
    //ここにSNSへの遷移(4ページ目)
     [self performSegueWithIdentifier:@"goSNS" sender:self];
}



@end
