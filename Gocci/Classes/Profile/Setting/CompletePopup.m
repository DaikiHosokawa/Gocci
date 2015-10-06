//
//  PopupViewController2.m
//  STPopup
//
//  Created by Kevin Lin on 11/9/15.
//  Copyright (c) 2015 Sth4Me. All rights reserved.
//

#import "CompletePopup.h"
#import "STPopup.h"

@interface CompletePopup (){
    UILabel *label;
}

@end

@implementation CompletePopup


- (instancetype)init
{
    if (self = [super init]) {
        self.contentSizeInPopup = CGSizeMake(300, 100);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 100);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"閉じる" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnDidTap)];
    
    label = [UILabel new];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"完了しました";
    label.font =  [UIFont fontWithName:@"Helvetica" size:16];
    [self.view addSubview:label];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    label.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, self.view.frame.size.height - 20);
}

- (void)nextBtnDidTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
