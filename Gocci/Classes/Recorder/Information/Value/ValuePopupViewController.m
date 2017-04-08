//
//  ValuePopupViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/21.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "ValuePopupViewController.h"
#import "STPopup.h"
#import "SingleLineTextField.h"
#import "AppDelegate.h"
#import "Swift.h"

@implementation ValuePopupViewController
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
    _label.text = @"価格を入力してください";
    _label.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
    _separatorView = [UIView new];
    _separatorView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_separatorView];
    
    _textField = [UITextField new];
    _textField.delegate = self;
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.placeholder = @"(例)1000 ";
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.delegate = self;
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    //numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)];
    button1.tintColor = [UIColor blackColor];
    UIBarButtonItem *button2 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *button3 = [[UIBarButtonItem alloc]initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(doneWithNumberPad)];
    button3.tintColor = [UIColor blackColor];
    button2.tintColor = [UIColor blackColor];
    numberToolbar.items = @[button1,button2, button3];
    [numberToolbar sizeToFit];
    _textField.inputAccessoryView = numberToolbar;

    [self.view addSubview:_textField];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _textField.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    _separatorView.frame = CGRectMake(0, _textField.frame.origin.y - 0.5, self.view.frame.size.width, 0.5);
    _label.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, self.view.frame.size.height - 20 - _textField.frame.size.height);
}



-(void)cancelNumberPad{
    
    [_textField resignFirstResponder];
    [self.popupController dismiss];

}

-(void)doneWithNumberPad{
    
    NSString *numberFromTheKeyboard = _textField.text;
    
    if([numberFromTheKeyboard length] > 0 ){
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:numberFromTheKeyboard forKey:@"value"];
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"ValueVCPopped" object:self userInfo:userInfo];
        [_textField resignFirstResponder];
        [self.view endEditing:YES];
        [self.popupController popViewControllerAnimated:YES];
       
    }else{
        [_textField resignFirstResponder];
        _label.text = @"1文字以上入力してください";
        _label.textColor = [UIColor redColor];

    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
 self.textField.placeholder = @"値段を入力";
 self.textField.keyboardType = UIKeyboardTypeNumberPad;
 self.textField.delegate = self;
 [self.view addSubview:self.textField];
 UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
 //numberToolbar.barStyle = UIBarStyleBlackTranslucent;
 numberToolbar.tintColor = [UIColor whiteColor];
 UIBarButtonItem *button1 = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)];
 button1.tintColor = [UIColor blackColor];
 UIBarButtonItem *button2 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
 UIBarButtonItem *button3 = [[UIBarButtonItem alloc]initWithTitle:@"OK" style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad)];
 button3.tintColor = [UIColor blackColor];
 button2.tintColor = [UIColor blackColor];
 numberToolbar.items = @[button1,button2, button3];
 [numberToolbar sizeToFit];
 self.textField.inputAccessoryView = numberToolbar;
 // Do any additional setup after loading the view.
 */

@end
