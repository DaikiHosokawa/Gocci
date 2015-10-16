//
//  PopupViewController3.m
//  STPopup
//
//  Created by Kevin Lin on 13/9/15.
//  Copyright (c) 2015 Sth4Me. All rights reserved.
//

#import "STPopup.h"
#import "CommentPopup.h"
#import "APIClient.h"

@interface CommentPopup () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@end


@implementation CommentPopup
{
    UILabel *_label;
    UITextField *_textField;
    UIImageView *_imageView;
    NSMutableSet *_mutableSelections;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
        self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 300);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _textField = [UITextField new];
    _textField.delegate = self;
    _textField.placeholder = @"ここに入力";
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_textField];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _textField.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
  
}

- (void)setDefaultSelections:(NSArray *)defaultSelections
{
    _defaultSelections = defaultSelections;
    _mutableSelections = [NSMutableSet setWithArray:defaultSelections];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text:%@",textField.text);
    
    if([textField.text length] > 0 ){
        [_mutableSelections addObject:textField.text];
        if ([self.delegate respondsToSelector:@selector(commentPopup:didFinishWithSelections:)]) {
            [self.delegate commentPopup:self didFinishWithSelections:_mutableSelections.allObjects];
        }
        [self.popupController popViewControllerAnimated:YES];
     
    }else{
    }

    return NO;
}

@end
