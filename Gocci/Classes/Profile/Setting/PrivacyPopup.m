//
//  PopupViewController1.m
//  STPopup
//
//  Created by Kevin Lin on 11/9/15.
//  Copyright (c) 2015 Sth4Me. All rights reserved.
//

#import "PrivacyPopup.h"
#import "STPopup.h"


@interface PrivacyPopup() <UIWebViewDelegate>

@end

@implementation PrivacyPopup
{
    UILabel *_label;
    UIWebView *_webView;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"プライバシーポリシー";
        self.contentSizeInPopup = CGSizeMake(300, 400);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"閉じる" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnDidTap)];
    
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.frame = self.view.frame;
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    
    //TODO change URL rule
    NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/?_rdr=p"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //   ページのロードが開始されたので、ステータスバーのロード中インジケータを表示する。
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _label.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, self.view.frame.size.height - 20);
}

- (void)nextBtnDidTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
