//
//  SCPostingViewController.m
//  Gocci
//
//  Created by INASE on 2015/05/08.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "SCPostingViewController.h"
#import "TabbarBaseViewController.h"
#import "SCRecorderViewController.h"
#import "AppDelegate.h"
#import "BFPaperCheckbox.h"
#import "SVProgressHUD.h"
#import "Swift.h"



static NSString * const SEGUE_GO_KAKAKUTEXT = @"goKakaku";
static NSString * const SEGUE_GO_BEFORE_RECORDER = @"goBeforeRecorder";
static NSString * const SEGUE_GO_HITOKOTO = @"goHitokoto";
static NSString * const CellIdentifier = @"CellIdentifierSocial";

@interface SCPostingViewController ()<BFPaperCheckboxDelegate>

{
    
    __weak IBOutlet UIImageView *imageview_samnail;
    
    SCSecondView *secondView;
    UITableView *tableviewSocial;
    __weak IBOutlet UIView *viewBase;
    __weak IBOutlet UITableView *tableviewTubuyaki;
    int SNStag;
    
}
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (retain) BFPaperCheckbox *checkbox1;
@property (nonatomic, copy) NSArray *checkboxes;


@end

@implementation SCPostingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%s %@",__func__, NSStringFromCGRect(self.view.frame) );
    
    // ???:ずれを解消出来る？
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //ナビゲーションバーに画像
    {
        //CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView = navigationTitle;
        
        //バックボタンカスタマイズ
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"Cancel";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
#if 1
    //情報テーブルビュー
    CGRect rect_second = CGRectMake(0, 246, 320, 170);	// 4inch
    {
        //画面サイズから場合分け
        CGRect rect = [UIScreen mainScreen].bounds;
        if (rect.size.height == 480) {
            //3.5inch
            rect_second = CGRectMake(0, 198, 320, 144);
        }
        else if (rect.size.height == 667) {
            //4.7inch
            rect_second = CGRectMake(0, 284, 375, 200);
        }
        else if (rect.size.height == 736) {
            //5.5inch
            rect_second = CGRectMake(0, 322, 414, 220);
        }
        
        secondView = [SCSecondView create];
        secondView.frame = rect_second;
        secondView.delegate = self;
        [secondView showInView:viewBase offset:CGPointZero back:1];
    }
    
    //ソーシャルテーブルビュー
    {
        CGRect rect_social = CGRectMake(0, rect_second.origin.y + rect_second.size.height, rect_second.size.width, rect_second.size.height/2);
        tableviewSocial = [[UITableView alloc] initWithFrame:rect_social   style:UITableViewStylePlain];
        //tableviewSocial.frame = rect_social;
        tableviewSocial.separatorColor = [UIColor clearColor];
        tableviewSocial.delegate = self;
        tableviewSocial.allowsSelection = NO;
        tableviewSocial.dataSource = self;
        tableviewSocial.scrollEnabled = NO;
        [self.view addSubview:tableviewSocial];
    }
    
#endif
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    NSLog(@"%s %@",__func__, NSStringFromCGRect(self.view.frame) );
    
    tableviewSocial.contentOffset = CGPointMake(0, 0);
}

-(void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"投稿画面：矩形：%@", NSStringFromCGRect(self.view.frame) );
    NSLog(@"%s %@",__func__, NSStringFromCGRect(self.view.frame) );
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"restrantname:%@",delegate.restname);
    if(delegate.restname)
    {
        NSLog(@"ある");
        _submitBtn.enabled = YES;
    }
    
    // NavigationBar 非表示
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%s %@",__func__, NSStringFromCGRect(self.view.frame) );
    
    
    //[secondView showInView:self.view offset:CGPointZero back:1];
    [self.view addSubview:tableviewSocial];
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [secondView setKakakuValue:delegate.valueKakaku];
    [secondView setTenmeiString:delegate.stringTenmei];
    [secondView setCategoryIndex:delegate.indexCategory];
    [secondView setFunikiIndex:delegate.indexFuniki];
    [secondView setHitokotoValue:delegate.valueHitokoto];
    [secondView reloadTableList];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        //NSLog(@" %s back!",__func__);
        // 戻るボタンが押された処理
        [[self viewControllerSCRecorder] cancelSubmit];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - アクション

//注意：投稿ボタンを押した時のアクション
- (IBAction)onSubmit:(id)sender
{
    /*
     //注意：Facebookシェアにチェックマークが入っている時
     if (SNStag == 2) {
     //注意：Facebookシェアにチェックマークが入っている時はSCRecorderViewControllerのrecorderSubmitPopupViewOnFacebookShareを呼ぶ
     [[self viewControllerSCRecorder] recorderSubmitPopupViewOnFacebookShare];
     }
     */
    [SVProgressHUD show];
    [[self viewControllerSCRecorder] execSubmit];
  }

#pragma mark - 取得
-(SCRecorderViewController*)viewControllerSCRecorder
{
    // ストーリーボードを取得
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:Util.getInchString bundle:nil];
    //ビューコントローラ取得
    return [storyboard instantiateViewControllerWithIdentifier:@"screcorder"];
}

#pragma mark - SCSecondView
-(void)goBeforeRecorder
{
    //遷移：beforeRecorderTableViewController
    [self performSegueWithIdentifier:SEGUE_GO_BEFORE_RECORDER sender:self];
}
-(void)goKakakuText
{
    [self showAlert];
    //遷移：SCRecorderVideoController
    //[self performSegueWithIdentifier:SEGUE_GO_KAKAKUTEXT sender:self];
    
}

-(void)goHitokotoText
{
    [self showAlert2];
    //遷移：SCRecorderVideoController
    //[self performSegueWithIdentifier:SEGUE_GO_HITOKOTO sender:self];
    
}

- (void)showAlert
{
    FirstalertView = [[UIAlertView alloc] initWithTitle:@"価格を入力してください"
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"OK", nil];
    FirstalertView.delegate       = self;
    FirstalertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[FirstalertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [FirstalertView show];
}


- (void)showAlert2
{
    SecondalertView = [[UIAlertView alloc] initWithTitle:@"一言を入力してください"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"OK", nil];
    SecondalertView.delegate       = self;
    SecondalertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [SecondalertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(FirstalertView == alertView){
        if( buttonIndex == alertView.cancelButtonIndex ) { return; }
        
        NSString* textValue = [[alertView textFieldAtIndex:0] text];
        if( [textValue length] > 0 )
        {
            // 入力内容を利用した処理
            NSLog(@"入力内容:%@",textValue);
            [self sendKakakuValue:[textValue intValue]];
            
            // !!!:dezamisystem・パラメータ
            AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [secondView setKakakuValue:delegate.valueKakaku];
            [secondView reloadTableList];
        }
    }
    if(SecondalertView == alertView){
        
        if( buttonIndex == alertView.cancelButtonIndex ) { return; }
        
        NSString* textValue = [[alertView textFieldAtIndex:0] text];
        if( [textValue length] > 0 )
        {
            // 入力内容を利用した処理
            NSLog(@"入力内容2:%@",textValue);
            [self sendHitokotoValue:textValue];
            
            // !!!:dezamisystem・パラメータ
            AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [secondView setHitokotoValue:delegate.valueHitokoto];
            [secondView reloadTableList];
            
        }
    }
}

#pragma mark - TableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = tableView.frame.size.height / 2;
    
    NSLog(@"%s %f",__func__, height);
    
    return height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    NSInteger row_index = indexPath.row;
    switch (row_index) {
            
        case 0:
            /*
             cell.textLabel.text = @"Facebookにシェアする";
             cell.imageView.image  = [UIImage imageNamed:@"table_facebook"];
             cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
             _checkbox1 =  [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(0, 0, bfPaperCheckboxDefaultRadius, bfPaperCheckboxDefaultRadius)];
             // button.frame = CGRectMake(0, 0, 30, 30);
             //  button.backgroundColor = [UIColor clearColor];
             _checkbox1.delegate = self;
             _checkbox1.tag = (1);
             cell.accessoryView = _checkbox1;
             */
            break;
            
            /*
             case 1:
             cell.textLabel.text = @"twitter";
             break;
             */
    }
    
    return cell;
}

#pragma mark 色変更
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor blackColor];
}

#pragma mark タップイベント
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            NSLog(@"%s facebook",__func__);
            
            break;
        case 1:
            NSLog(@"%s twitter",__func__);
            [[self viewControllerSCRecorder] recorderSubmitPopupViewOnTwitterShare];
            break;
            
    }
    
    // 選択状態の解除
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)paperCheckboxChangedState:(BFPaperCheckbox *)changedCheckbox
{
    if (!changedCheckbox.isChecked) {
        if((changedCheckbox.tag)==1){
            // TODO: チェックボックス選択時の処理
            SNStag = 1;
            LOG(@"Facebookシェアを解除しました,SNStag=%d",SNStag);
        }
        
    }else{
        if((changedCheckbox.tag)==1){
            // TODO: チェックボックス選択時の処理
            SNStag = 2;
            LOG(@"Facebookシェアを選択しました,SNStag=%d",SNStag);
            [[self viewControllerSCRecorder] recorderSubmitPopupViewOnFacebookShare:self];
        }
    }
}

#pragma mark - KakakuTextViewController
-(void)sendKakakuValue:(int)value
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.valueKakaku = value;
}

-(void)sendHitokotoValue:(NSString *)value
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.valueHitokoto = value;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)afterRecording:(UIViewController *)viewController
{
    NSLog(@"呼ばれてはいる");
    [self dismissViewControllerAnimated:YES completion:^() {
        [self performSegueWithIdentifier:@"afterRecording" sender:self];
    }];
}
 

@end
