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

static NSString * const sampleDescription1 = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
static NSString * const sampleDescription2 = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
static NSString * const sampleDescription3 = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
static NSString * const sampleDescription4 = @"Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit.";

@interface TutorialViewController ()<TutorialViewDelegate>

@property (nonatomic, strong) TutorialView *tutorialView;

@end


@implementation TutorialViewController{
    UIView *rootView;
    EAIntroView *_intro;
}


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    // using self.navigationController.view - to display EAIntroView above navigation bar
    rootView = self.navigationController.view;
    
}

-(void)viewDidAppear{
    [super viewDidAppear:YES];
    
    [self showIntroWithCustomViewFromNib];
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

- (void)showIntroWithCustomViewFromNib {
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Hello world";
    page1.desc = sampleDescription1;
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"This is page 3";
    page2.desc = sampleDescription3;
    page2.bgImage = [UIImage imageNamed:@"bg3"];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];
    
    EAIntroPage *page3 = [EAIntroPage pageWithCustomViewFromNibNamed:@"IntroPage"];
    page3.bgImage = [UIImage imageNamed:@"bg2"];

    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3]];
    [intro setDelegate:self];
    
    UISwitch *switchControl = (UISwitch *)[page3.pageView viewWithTag:1];
    if(switchControl) {
        [switchControl addTarget:self action:@selector(switchFlip:) forControlEvents:UIControlEventValueChanged];
    }
    
    [intro showInView:rootView animateDuration:0.1];
    _intro = intro;
    
}


- (IBAction)switchFlip:(id)sender {
    UISwitch *switchControl = (UISwitch *) sender;
    NSLog(@"%@", switchControl.on ? @"On" : @"Off");
    
    // limit scrolling on one, currently visible page (can't go previous or next page)
    //[_intro setScrollingEnabled:switchControl.on];
    
    if(!switchControl.on) {
        // scroll no further selected page (can go previous pages, but not next)
        [_intro limitScrollingToPage:_intro.visiblePageIndex];
    } else {
        [_intro setScrollingEnabled:YES];
    }
}

@end
