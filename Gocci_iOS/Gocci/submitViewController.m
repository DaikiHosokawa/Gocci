//
//  submitViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "submitViewController.h"
#import "AppDelegate.h"
#import "EDStarRating.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking/AFNetworking.h"


@interface submitViewController ()<UITextViewDelegate>

- (IBAction)submitFacebook:(UIButton *)sender;
- (IBAction)submitTwitter:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet EDStarRating *starRatingImage;
@property NSString *text;
@property UITextView *textView;
@property NSMutableString *str;
@property NSString *ratingString;


@end

@implementation submitViewController




@synthesize starRatingImage = _starRatingImage;

/*
//テキストビューの文字数宣言
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    // 入力済みのテキストを取得
    _str = [_textView.text mutableCopy];
    
    // 入力済みのテキストと入力が行われたテキストを結合
    [_str replaceCharactersInRange:range withString:text];
    NSLog(@"%@",_str);
    
   
    if ([text isEqualToString:@"\n"]) {
        [_textView resignFirstResponder];
        return NO;
    }

    return YES;
}
*/
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    sleep(3);
    [super viewDidLoad];
    
    self.navigationItem.title = @"投稿画面";
    
    /*
    // Do any additional setup after loading the view.
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.layer.borderWidth = 1;
    _textView.clipsToBounds = YES;
    _textView.layer.cornerRadius = 10.0f;
    */
     
    // Setup control using image
    //_starRatingImage.backgroundImage=[UIImage imageNamed:@"starsbackground iOS.png"];
    _starRatingImage.starImage = [UIImage imageNamed:@"hosi nasi23.png"];
    _starRatingImage.starHighlightedImage = [UIImage imageNamed:@"hosi23.png"];
    _starRatingImage.maxRating = 5.0;
    _starRatingImage.delegate = self;
    _starRatingImage.horizontalMargin = 12;
    _starRatingImage.editable=YES;
    _starRatingImage.rating= 3;
    _starRatingImage.displayMode=EDStarRatingDisplayAccurate;
    [self starsSelectionChanged:_starRatingImage rating:3];
    // This one will use the returnBlock instead of the delegate
    _starRatingImage.returnBlock = ^(float rating )
    {
        NSLog(@"ReturnBlock: Star rating changed to %.1f", rating);
        // For the sample, Just reuse the other control's delegate method and call it
        [self starsSelectionChanged:_starRatingImage rating:rating];
    };
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    _ratingString = [NSString stringWithFormat:@"Rating:%.1f", rating];

    NSLog(@"ratingString:%@",_ratingString);
}

- (void)viewDidUnload
{
    [self setStarRatingImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // キーボードを隠す
    [_textView resignFirstResponder];
    return YES;
}
*/
 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Twitterの投稿
- (IBAction)submitTwitter:(UIButton*)sender {
 [self postMedia:SLServiceTypeTwitter];
}

-(void) postMedia:(NSString*)type
{
    
    NSString *serviceType = type;
    //if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
    
    SLComposeViewController *viewController = [SLComposeViewController
                                               composeViewControllerForServiceType:serviceType];
    
//リゲートの値を取得するときは、このメソッドを使用する。
    AppDelegate *appDelegete2 = [[UIApplication sharedApplication] delegate];
    NSString *filename = [appDelegete2.postMovieURL lastPathComponent];
    NSString* stringA = @"http://api-gocci.jp/movies/";
    NSString* entitystring  = [NSString stringWithFormat:@"%@%@",stringA,filename];
    NSURL *holeurl = [NSURL URLWithString:entitystring];
    NSLog(@"holeurl:%@",holeurl);
    [viewController setInitialText:@"グルメ動画アプリ「Gocci」からの投稿"];
    [viewController addURL:holeurl]; //URLのセット
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


//Facebookの投稿
- (IBAction)submitFacebook:(UIButton *)sender {
     [SVProgressHUD showWithStatus:@"紹介中" maskType:SVProgressHUDMaskTypeAnimation];

     
     
    //プライバシー(公開範囲)の設定
    NSDictionary* privacy = @{@"value":@"CUSTOM", @"friends":@"ALL_FRIENDS"};
    NSError*error2 =nil;
    NSData*data2 =[NSJSONSerialization dataWithJSONObject:privacy options:2 error:&error2];
    NSString*jsonstr=[[NSString alloc]initWithData:data2 encoding:NSUTF8StringEncoding];
    
    AppDelegate *movieDelegete = [[UIApplication sharedApplication] delegate];
    AppDelegate *restaurantDelegate = [[UIApplication sharedApplication] delegate];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *filePath =  [bundle pathForResource:@"vvideo" ofType:@"mp4"];
    NSLog(@"filePath:%@",filePath);
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSLog(@"data:%@",data);
    NSString *message = @"Gocciからの投稿";
    
    NSMutableDictionary* params = @{@"message":message,
                                    @"privacy":jsonstr,
                                    @"movie.mp4":movieDelegete.movieData,
                                    @"title":restaurantDelegate.gText,
                                    }.mutableCopy;
    
    //FBリクエストの作成
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/videos"
                                              parameters:params
                                              HTTPMethod:@"POST"];
    
    
    //コネクションをセットしてすぐキャンセル→NSMutableURLRequestを生成するため???
    //ここはStack Overflowの受け売り
    FBRequestConnection *requestConnection = [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    }];
    [requestConnection cancel];
    
    //リクエストの作成
    NSMutableURLRequest *urlRequest = requestConnection.urlRequest;
    
    //送信！
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Do your success callback.
        NSLog(@"success!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do your failure callback.
        NSLog(@"fail!");
        NSLog(@"operation=%@",operation);
        NSLog(@"error=%@",error);
    }];
    
    
    [[NSOperationQueue mainQueue] addOperation:operation];
   
    
    [SVProgressHUD dismiss];
}



- (IBAction)pushComplete:(id)sender {
    {
        NSLog(@"pushCompleteを押したよ");
    // 文字列を数値型へ変換する。
    NSString *substr2 = [_ratingString stringByReplacingOccurrencesOfString:@"Rating:" withString:@""];
    NSLog(@"substr2:%@",substr2);
    NSInteger i = substr2.integerValue;
    NSString *content = [NSString stringWithFormat:@"star_evaluation=%ld",(long)i];
    NSLog(@"content:%@",content);
	NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/submit/"];
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