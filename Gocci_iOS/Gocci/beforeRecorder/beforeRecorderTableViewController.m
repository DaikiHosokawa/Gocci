//
//  beforeRecorderTableViewController.m
//  Gocci
//
//  Created by デザミ on 2015/02/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "beforeRecorderTableViewController.h"
#import "AppDelegate.h"
#import "SCRecorderViewController.h"
#import "SampleTableViewCell.h"

static NSString * const SEGUE_GO_SC_RECORDER = @"goSCRecorder";


@interface beforeRecorderTableViewController ()

@property (nonatomic, strong) NSMutableArray *restname_;
@property (nonatomic, strong) NSMutableArray *category_;
@property (nonatomic, strong) NSMutableArray *meter_;
@property (nonatomic, strong) NSMutableArray *jsonlat_;
@property (nonatomic, strong) NSMutableArray *jsonlon_;
@property (nonatomic, strong) NSMutableArray *restaddress_;
@property (nonatomic, strong) NSString *nowlat_;
@property (nonatomic, strong) NSString *nowlon_;

@end

@implementation beforeRecorderTableViewController

#pragma mark - アイテム名登録用
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
         UIImage *image = [[UIImage imageNamed:@"tabbaritem_posting.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.image = image;
        UIImage *image_sel = [[UIImage imageNamed:@"tabbaritem_posting_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = image_sel;
	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    AppDelegate *appDelegete = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //dispatch_queue_t q2_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_queue_t q2_main = dispatch_get_main_queue();
    //dispatch_async(q2_global, ^{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 飲食店名
        NSArray *restname = [appDelegete.jsonDic valueForKey:@"restname"];
        _restname_ = [restname mutableCopy];
        // 店舗カテゴリー
        NSArray *category = [appDelegete.jsonDic valueForKey:@"category"];
        _category_ = [category mutableCopy];
        // 距離
        NSArray *meter = [appDelegete.jsonDic valueForKey:@"distance"];
        _meter_ = [meter mutableCopy];
        // 店舗住所
        NSArray *restaddress = [appDelegete.jsonDic valueForKey:@"locality"];
        _restaddress_ = [restaddress mutableCopy];
        
        //緯度
        NSArray *jsonlat = [appDelegete.jsonDic valueForKey:@"lat"];
        _jsonlat_ = [jsonlat mutableCopy];
        //経度
        NSArray *jsonlon = [appDelegete.jsonDic valueForKey:@"lon"];
        _jsonlon_ = [jsonlon mutableCopy];
        //dispatch_async(q2_main, ^{
        [self.tableView reloadData];
        //});
    });
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
    //カスタムセルの導入
    UINib *nib = [UINib nibWithNibName:@"SampleTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"searchTableViewCell"];
  
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
//	UIImage *image = [[UIImage imageNamed:@"tabbaritem_posting.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//	self.tabBarItem.image = image;

	[super viewDidAppear:animated];
}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
////#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_restname_ count];
}

//テーブルセルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SampleTableViewCell *cell = (SampleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"searchTableViewCell"];
    
    cell.restaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    cell.restaurantAddress.text = [_restaddress_ objectAtIndex:indexPath.row];
    cell.meter.text= [_meter_ objectAtIndex:indexPath.row];
    cell.meter.textAlignment = NSTextAlignmentRight;
    cell.categoryname.text = [_category_ objectAtIndex:indexPath.row];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%s",__func__);
    
    NSString *postRestName = [_restname_ objectAtIndex:indexPath.row];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.gText = postRestName;

	//遷移：SCRecorderVideoController
	[self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER sender:self];

	// 選択状態の解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	//2つ目の画面にパラメータを渡して遷移する
	// !!!:dezamisystem
	if ([segue.identifier isEqualToString:SEGUE_GO_SC_RECORDER])
	{
		//ここでパラメータを渡す
		SCRecorderViewController *recVC = segue.destinationViewController;
		//recVC.postID = (NSString *)sender;
		recVC.hidesBottomBarWhenPushed = YES;	// タブバー非表示
	}
}


@end
