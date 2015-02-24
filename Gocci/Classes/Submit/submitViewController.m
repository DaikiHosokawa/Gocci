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
#import "AFNetworking.h"

#import "TimelineTableViewController.h"


// !!!:dezamisystem
static NSString * const SEGUE_GO_BACK_TIMELINE = @"gobackTimeline";


@interface submitViewController ()<UITextViewDelegate>
{
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
}

- (void)showDefaultContentView;

- (IBAction)submitFacebook:(UIButton *)sender;
- (IBAction)submitTwitter:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet EDStarRating *starRatingImage;
@property NSString *text;
@property UITextView *textView;
@property NSMutableString *str;
@property NSString *ratingString;


@end

@implementation submitViewController
// !!!:dezamisystem
//@synthesize textView;



@synthesize starRatingImage = _starRatingImage;


#pragma mark - アイテム名登録用
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		// !!!:dezamisystem・アイテム名
		[self setTitle:@"Submit"];
	}
	return self;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	// !!!:dezamisystem
	[self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    sleep(3);
    [super viewDidLoad];
	
	//ナビゲーションバーに画像
	{
		//タイトル画像設定
		CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
		CGFloat width_image = height_image;
		UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
		UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
		self.navigationItem.titleView =navigationTitle;
	}

	// !!!:dezamisystem
//	self.navigationItem.title = @"投稿画面";

}

/*
-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    _ratingString = [NSString stringWithFormat:@"Rating:%.1f", rating];

    NSLog(@"ratingString:%@",_ratingString);
}
 */

- (void)viewDidUnload
{
    [self setStarRatingImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isFirstRun]) {
        //Calling this methods builds the intro and adds it to the screen. See below.
        [self showDefaultContentView];
    }
}

- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate8"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate8"];
    // 保存
    [userDefaults synchronize];
    // 初回起動
    return YES;
}

- (void)showDefaultContentView
{
    if (!_firstContentView) {
        _firstContentView = [DemoContentView defaultView];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(20, 8, 260, 100);
        descriptionLabel.numberOfLines = 0.;
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:18.];
        descriptionLabel.text = @"最後に星をつけて”完了”を押せば投稿完了です！";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
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
    AppDelegate *appDelegete2 = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //NSString *filename = [appDelegete2.postMovieURL lastPathComponent];
    NSString* stringA = @"http://api-gocci.jp/movies/";
    NSString* entitystring  = [NSString stringWithFormat:@"%@%@",stringA,appDelegete2.postFileName];
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
    
    AppDelegate *movieDelegete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AppDelegate *restaurantDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
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
		[SVProgressHUD showWithStatus:@"投稿中" maskType:SVProgressHUDMaskTypeAnimation];
#if (!TARGET_IPHONE_SIMULATOR)
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
        
        /*
		if (result) {
			//
		}
         */
#endif
		// !!!:dezamisystem
		// [self performSegueWithIdentifier:@"gobackTimeline" sender:self];
		
		//[self performSegueWithIdentifier:SEGUE_GO_BACK_TIMELINE sender:self];
		[self dismissViewControllerAnimated:YES completion:^{
			//
			NSLog(@"Return to beforeRecord");
		}];
		
		//NSLog(@"Go back to Timeline");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
	
	//2つ目の画面にパラメータを渡して遷移する
	// !!!:dezamisystem
	if ([segue.identifier isEqualToString:SEGUE_GO_BACK_TIMELINE])
	{
		//ここでパラメータを渡す
		TimelineTableViewController *timeVC = segue.destinationViewController;
		//recVC.postID = (NSString *)sender;
		timeVC.hidesBottomBarWhenPushed = NO;	// タブバー表示
	}
}


@end