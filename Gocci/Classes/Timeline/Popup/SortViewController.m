//
//  SortViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/13.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "SortViewController.h"
#import "STPopup.h"
#import "ValueViewController.h"

@interface SortViewController ()

@end

@implementation SortViewController
@synthesize category = _category;
@synthesize value = _value;

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"絞り込み";
        self.contentSizeInPopup = CGSizeMake(300, 90);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 40);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(OKBtnDidTap)];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Identifier"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recvData:)
                                                 name:@"CategoryVCPopped"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recvData2:)
                                                 name:@"ValueVCPopped"
                                               object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"カテゴリー";
        if (self.category) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"カテゴリー：",self.category];;
        }
    }else{
         cell.textLabel.text = @"価格";
        if (self.value) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"価格：",self.value];;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        CategoryViewController* cvc = [CategoryViewController new];
        cvc.timelinePageMenuViewController = self.timelinePageMenuViewController;
       [self.popupController pushViewController:cvc animated:YES];
    }else{
        ValueViewController* vvc = [ValueViewController new];
        vvc.timelinePageMenuViewController = self.timelinePageMenuViewController;
        [self.popupController pushViewController:vvc animated:YES];
    }
}

//[self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortValue:@"4"];

- (void) recvData:(NSNotification *) notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString * data = [userInfo objectForKey:@"category"];
    NSString * data2 = [userInfo objectForKey:@"category_flag"];
    NSLog (@"カテゴリー:%@,%@", data,data2);
    self.category = data;
    self.category_flag = data2;
    [self.tableView reloadData];
}

- (void) recvData2:(NSNotification *) notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString * data = [userInfo objectForKey:@"value"];
    NSString * data2 = [userInfo objectForKey:@"value_flag"];
    NSLog (@"価格:%@,%@", data,data2);
    self.value = data;
    self.value_flag = data2;
    [self.tableView reloadData];
}

- (void)OKBtnDidTap
{
    if([self.value_flag compare:@""] == NSOrderedSame){
        self.value_flag = @"";
    }
    if([self.category_flag compare:@""] == NSOrderedSame){
        self.category_flag = @"";
    }
    [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sort:self.value_flag category:self.category_flag];
   // [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortValue:@"4"];
    [self.popupController dismiss];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
