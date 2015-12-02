//
//  ValueViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/22.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "ValueViewController.h"
#import "STPopup.h"

@interface ValueViewController ()

@end

@implementation ValueViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"価格";
        self.contentSizeInPopup = CGSizeMake(300, 220);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 130);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Identifier"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    if (indexPath.row == 0) {
      cell.textLabel.text = @"指定なし";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"¥1~700";
    }else if(indexPath.row == 2) {
        cell.textLabel.text = @"￥500~1500";
    }else if(indexPath.row == 3) {
        cell.textLabel.text = @"￥1500~5000";
    }else if(indexPath.row == 4) {
        cell.textLabel.text = @"￥3000~";
    }
    
    return cell;
}


//1: I want to call method in AllTimelineTableViewController's method from this
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortValue:@""];
        [self.popupController dismiss];
    }
    else if (indexPath.row == 1) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortValue:@"1"];
        [self.popupController dismiss];
    }else if(indexPath.row == 2) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortValue:@"2"];
        [self.popupController dismiss];
    }else if(indexPath.row == 3) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortValue:@"3"];
        [self.popupController dismiss];
    }else if(indexPath.row == 4) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortValue:@"4"];
        [self.popupController dismiss];
    }
    
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
