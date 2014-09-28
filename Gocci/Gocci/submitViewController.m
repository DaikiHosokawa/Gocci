//
//  submitViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "submitViewController.h"
#import "CaptureManager.h"

@interface submitViewController ()<UITextViewDelegate>

- (IBAction)submitFacebook:(UIButton *)sender;
- (IBAction)submitTwitter:(UIButton *)sender;
@property NSString *text;
@property UITextView *textView;
@property NSMutableString *str;

@end

@implementation submitViewController

//テキストビューの文字数宣言
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    int maxInputLength = 20;
    
    // 入力済みのテキストを取得
    _str = [_textView.text mutableCopy];
    
    // 入力済みのテキストと入力が行われたテキストを結合
    [_str replaceCharactersInRange:range withString:text];
    NSLog(@"%@",_str);
    
    if ([_str length] > maxInputLength) {
        return NO;
}
    return YES;
}

/*

-(BOOL)textViewShouldEndEditing:
(UITextView*)textView{
    _text = _textView.text;
    NSLog(@"text:%@",_text);
    return YES;
}
 */
 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.layer.borderWidth = 1;
    _textView.clipsToBounds = YES;
    _textView.layer.cornerRadius = 10.0f;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // キーボードを隠す
    [_textView resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//Twitterの投稿
- (IBAction)submitTwitter:(UIButton*)sender {
        [self postMedia:SLServiceTypeTwitter];
    }

//Facebookの投稿
- (IBAction)submitFacebook:(UIButton *)sender {
        [self postMedia:SLServiceTypeFacebook];
    }
    
-(void) postMedia:(NSString*)type
{
        NSString *serviceType = type;
        //if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        
        SLComposeViewController *viewController = [SLComposeViewController
                                                   composeViewControllerForServiceType:serviceType];
    
        NSString* path = @"http://codecamp1353.lesson2.codecamp.jp/movies/mergeVideo-866.mp4";
        NSURL* url = [NSURL URLWithString:path];
        /*
        NSData* data = [NSData dataWithContentsOfURL:url];
         UIImage* img = [[UIImage alloc] initWithData:data];
         [viewController addImage:img];
       */
         [viewController setInitialText:@"グルメ動画アプリ「Gocci」からの投稿"];
        [viewController addURL:url]; //URLのセット
    
        viewController.completionHandler = ^(SLComposeViewControllerResult res) {
            if (res == SLComposeViewControllerResultCancelled) {
                NSLog(@"cancel");
            }
            else if (res == SLComposeViewControllerResultDone) {
                NSLog(@"done");
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        };
        [self presentViewController:viewController animated:YES completion:nil];
        
    }



- (IBAction)pushComplete:(id)sender {
    
     /*
      NSString *query = [NSString stringWithFormat:@"str=%@",_text];
     NSData *queryData = [query dataUsingEncoding:NSUTF8StringEncoding];
     
     NSString *url = @"https://codelecture.com/gocci/movie.php";
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
     [request setURL:[NSURL URLWithString:url]];
     [request setHTTPMethod:@"POST"];
     [request setHTTPBody:queryData];
     
     NSURLResponse *response;
     NSError *error;
     
     NSData *result = [NSURLConnection sendSynchronousRequest:request
     returningResponse:&response
     error:&error];
     NSString *string = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
     NSLog(@"%@", string);
 */
   /*
    NSURL* url = [NSURL URLWithString:@"https://codelecture.com/gocci/movie.php"];//POST先url
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSString *text = [NSString stringWithFormat:@"id=%@",_text];//_textはテキストビューの入力内容
    NSLog(@"text:%@",text);//str=(テキストビューへの入力内容)と出力される※確認済
    [request setHTTPBody: [text dataUsingEncoding: NSUTF8StringEncoding]];
    //NSData *queryData = [text dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"queryData:%@",queryData);
    request.HTTPMethod = @"POST";
    request.HTTPBody = queryData;
    NSLog(@"httpbody:%@",request.HTTPBody);
    [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
   [request setValue: [NSString stringWithFormat: @"%lu", (unsigned long)[queryData length]] forHTTPHeaderField: @"Content-Length"];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        // 完了時の処理
        if (![_text isEqual:[NSNull null]])
        {
        _text = nil;
        }
        NSLog(@"task:%@",task);
                                            }];
    [task resume];
    */
    // NSString *content = [NSString stringWithFormat:@"str=%@",_text];
    
    if (_textView.text.length == 0) {
        //アラート出す
        NSLog(@"textlength:%lu",(unsigned long)_textView.text.length);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"レビューを入力してください"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }else{
     _text = _textView.text;
    NSString *content = [NSString stringWithFormat:@"val=%@",_text];
	NSURL* url = [NSURL URLWithString:@"https://codelecture.com/gocci/submit/submit.php"];
	NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
	NSURLResponse* response;
	NSError* error = nil;
	NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
										   returningResponse:&response
													   error:&error];
    
    
        
        [self performSegueWithIdentifier:@"gobackTimeline" sender:self];
        NSLog(@"Go back to Timeline");
    }
}

@end