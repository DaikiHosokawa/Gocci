//
//  TutorialViewController.m
//  Gocci
//
//  Created by Castela on 2015/08/25.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "TutorialViewController.h"


static NSString * const sampleDescription1 = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
static NSString * const sampleDescription2 = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
static NSString * const sampleDescription3 = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
static NSString * const sampleDescription4 = @"Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit.";

@interface TutorialViewController ()<UITextFieldDelegate>


@property (weak, nonatomic)  UITextField *usernameField;


@end


@implementation TutorialViewController{
    UIView *rootView;
    EAIntroView *_intro;
}


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    // using self.navigationController.view - to display EAIntroView above navigation bar
    rootView = self.view;
    
    [self showIntroWithCustomViewFromNib];
}

-(void)viewDidAppear{
    [super viewDidAppear:YES];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

#pragma mark - TutorialView Delegate


- (void)goSNS
{
    
    NSLog(@"call goSNS method");
    //ここにSNSへの遷移(4ページ目)
     [self performSegueWithIdentifier:@"goSNS" sender:self];
    
}

- (void)showIntroWithCustomViewFromNib {
    
    NSLog(@"showTutorial");
    
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
    intro.pageControlY = 250.f;
    [intro setDelegate:self];
    
    UISwitch *switchControl = (UISwitch *)[page3.pageView viewWithTag:1];
    if(switchControl) {
        [switchControl addTarget:self action:@selector(switchFlip:) forControlEvents:UIControlEventValueChanged];
    }
    
    _usernameField = (UITextField *)[page3.pageView viewWithTag:2];
    if(_usernameField){
        [_usernameField addTarget:self action:@selector(done:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(0, 0, 250, 40)];
    [btn setTitle:@"すでにアカウントお持ちの方は..." forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.borderWidth = 2.f;
    btn.layer.cornerRadius = 10;
    btn.layer.borderColor = [[UIColor whiteColor] CGColor];
    intro.skipButton = btn;
    intro.skipButtonY = 60.f;
    intro.skipButtonAlignment = EAViewAlignmentCenter;
    
    [intro setDelegate:self];
    [intro showInView:rootView animateDuration:0.1];
    _intro = intro;
    
}


- (IBAction)tapButton:(id)sender {
    
    [self showIntroWithCustomViewFromNib];
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

/**
 * キーボードでReturnキーが押されたとき
 * @param textField イベントが発生したテキストフィールド
 */
- (void)done:(id)sender
{
    NSLog(@"text:%@",_usernameField.text);
    // キーボードを隠す
    [sender resignFirstResponder];
    
    [self goSNS];
}
@end
