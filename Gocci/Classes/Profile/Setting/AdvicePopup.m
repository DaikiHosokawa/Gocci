//
//  PopupViewController3.m
//  STPopup
//
//  Created by Kevin Lin on 13/9/15.
//  Copyright (c) 2015 Sth4Me. All rights reserved.
//

#import "AdvicePopup.h"
#import "STPopup.h"
#import "CompletePopup.h"
#import "APIClient.h"

@interface AdvicePopup () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@end


@implementation AdvicePopup
{
    UILabel *_label;
    UIView *_separatorView;
    UITextField *_textField;
    UIImageView *_imageView;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.contentSizeInPopup = CGSizeMake(300, 100);
        self.landscapeContentSizeInPopup = CGSizeMake(300, 200);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _label = [UILabel new];
    _label.numberOfLines = 0;
    _label.text = @"下に意見/要望をご入力ください";
    _label.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
    _separatorView = [UIView new];
    _separatorView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_separatorView];
    
    _textField = [UITextField new];
    _textField.delegate = self;
    _textField.placeholder = @"ここに入力";
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_textField];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _textField.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    _separatorView.frame = CGRectMake(0, _textField.frame.origin.y - 0.5, self.view.frame.size.width, 0.5);
    _label.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, self.view.frame.size.height - 20 - _textField.frame.size.height);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text:%@",textField.text);
    
    if([textField.text length] > 0 ){
        
        [APIClient postFeedback:textField.text handler:^(id result, NSUInteger code, NSError *error) {
            if (code == 200){
                [textField resignFirstResponder];
                [self.popupController pushViewController:[CompletePopup new] animated:YES];
            }
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
        }
         ];
    }else{
        _label.text = @"1文字以上入力してください";
        _label.textColor = [UIColor redColor];
    }

    return NO;
}

@end
