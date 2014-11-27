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

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
}



- (void)viewDidLoad
{
    sleep(3);
    [super viewDidLoad];
 
    // UIImageを指定した生成例
    UIImage *image = [UIImage imageNamed:@"gocci-moji.png"];
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = myImageView;
    
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
    
      //デリゲートの値を取得するときは、このメソッドを使用する。
      AppDelegate *appDelegete2 = [[UIApplication sharedApplication] delegate];
       NSString *filename = [appDelegete2.postMovieURL lastPathComponent];
       NSString* stringA = @"http://api-gocci.jp/api/public/movies/";
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



- (IBAction)pushComplete:(id)sender {
    {
        NSLog(@"pushCompleteを押したよ");
        
    [SVProgressHUD showWithStatus:@"投稿中" maskType:SVProgressHUDMaskTypeAnimation];
        
    // 文字列を数値型へ変換する。
    NSString *substr2 = [_ratingString stringByReplacingOccurrencesOfString:@"Rating:" withString:@""];
    NSLog(@"substr2:%@",substr2);
    NSInteger i = substr2.integerValue;
    NSString *content = [NSString stringWithFormat:@"tar_evaluation=%ld",(long)i];
    NSLog(@"content:%@",content);
	NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/submit/"];
	NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
	NSURLResponse* response;
	NSError* error = nil;
	NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
										   returningResponse:&response
													   error:&error];
        sleep(3);
        //[SVProgressHUD dismiss];
        [self performSegueWithIdentifier:@"gobackTimeline" sender:self];
        NSLog(@"Go back to Timeline");
    }
}

@end