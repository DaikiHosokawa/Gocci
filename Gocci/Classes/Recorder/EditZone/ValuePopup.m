//
//  PopupViewController3.m
//  STPopup
//
//  Created by Kevin Lin on 13/9/15.
//  Copyright (c) 2015 Sth4Me. All rights reserved.
//

#import "STPopup.h"
#import "ValuePopup.h"
#import "APIClient.h"
#import "SingleLineTextField.h"

@interface ValuePopup () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SingleLineTextField *textField;
@end


@implementation ValuePopup
{
    UILabel *_label;
    UIImageView *_imageView;
    NSMutableSet *_mutableSelections;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 100);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.textField.lineDisabledColor = [UIColor cyanColor];
    self.textField.lineNormalColor = [UIColor grayColor];
    self.textField.lineSelectedColor = [UIColor blueColor];
    self.textField.inputTextColor = [UIColor blackColor];
    self.textField.inputPlaceHolderColor = [UIColor greenColor];
    [[SingleLineTextField appearance] setLineDisabledColor:[UIColor cyanColor]];
    [[SingleLineTextField appearance] setLineNormalColor:[UIColor grayColor]];
    [[SingleLineTextField appearance] setLineSelectedColor:[UIColor blueColor]];
    [[SingleLineTextField appearance] setInputPlaceHolderColor:[UIColor grayColor]];
    [[SingleLineTextField appearance] setInputFont:[UIFont boldSystemFontOfSize:22]];
    [[SingleLineTextField appearance] setPlaceHolderFont:[UIFont boldSystemFontOfSize:22]];
    self.textField.placeholder = @"値段を入力";
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.delegate = self;
    [self.view addSubview:self.textField];
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.textField.inputAccessoryView = numberToolbar;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _textField.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
}

-(void)cancelNumberPad{

    [self.textField resignFirstResponder];
    [self.popupController popViewControllerAnimated:YES];
}

-(void)doneWithNumberPad{
    
    NSString *numberFromTheKeyboard = self.textField.text;
    
    if([numberFromTheKeyboard length] > 0 ){
        [_mutableSelections addObject:numberFromTheKeyboard];
        if ([self.delegate respondsToSelector:@selector(valuePopup:didFinishWithSelections:)]) {
            [self.delegate valuePopup:self didFinishWithSelections:_mutableSelections.allObjects];
        }
        [self.popupController popViewControllerAnimated:YES];
        
    }else{
    }
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
        if ([self.delegate respondsToSelector:@selector(valuePopup:didFinishWithSelections:)]) {
            [self.delegate valuePopup:self didFinishWithSelections:_mutableSelections.allObjects];
        }
        [self.popupController popViewControllerAnimated:YES];
        
    }else{
    }
    
    return NO;
}

@end
