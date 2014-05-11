//
//  ViewController.m
//  Swipemenu
//
//  Created by Daiki Hosokawa on 2014/05/11.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MIRevealTableViewCell *cell = (MIRevealTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MIRevealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        ...
    }
    cell.revealCellDelegate = self;
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - reveal cell delegate

// セルのタッチが開始された
- (void)revealTableViewCellWillBBeginTouchesCell:(MIRevealTableViewCell*)cell {
    if (cell != self.activeCell) {
        [self.activeCell hideBackContentViewAnimated:YES];
        self.activeCell = nil;
    }
}

// 開こうとしている
- (void)revealTableViewCellWillShowBackContentView:(MIRevealTableViewCell*)cell {
    self.activeCell = cell;
}

// 閉じようとしている
- (void)revealTableViewCellWillHideBackContentView:(MIRevealTableViewCell*)cell {
    self.activeCell = nil;
}

#pragma mark - scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.activeCell hideBackContentViewAnimated:YES];
}

@end
