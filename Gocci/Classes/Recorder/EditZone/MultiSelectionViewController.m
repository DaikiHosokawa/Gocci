//
//  MultiSelectionViewController.m
//  STPopup
//
//  Created by Kevin Lin on 11/10/15.
//  Copyright © 2015 Sth4Me. All rights reserved.
//

#import "MultiSelectionViewController.h"
#import "STPopup.h"

@interface MultiSelectionViewController ()

- (IBAction)done:(id)sender;

@end

@implementation MultiSelectionViewController
{
    NSMutableSet *_mutableSelections;
    NSMutableSet *_postParams;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 300);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.height, 300);
}

- (void)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(multiSelectionViewController:didFinishWithSelections:post_param:)]) {
        [self.delegate multiSelectionViewController:self didFinishWithSelections:_mutableSelections.allObjects post_param:_postParams.allObjects];
    }
    [self.popupController popViewControllerAnimated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"Multi-Selection Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSString *item = self.items[indexPath.row];
    
    cell.textLabel.text = item;
    cell.tintColor = [UIColor blackColor];
    cell.accessoryType = [_mutableSelections containsObject:item] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_mutableSelections) {
        _mutableSelections = [NSMutableSet new];
        _postParams = [NSMutableSet new];
    }
    
    NSString *item = self.items[indexPath.row];
    NSString *post_item = self.post_param[indexPath.row];
    
    if (![_mutableSelections containsObject:item]&&[_mutableSelections count]<1) {
        [_mutableSelections addObject:item];
         [_postParams addObject:post_item];
        NSLog(@"追加");
    }
    else {
        [_mutableSelections removeObject:item];
         [_postParams addObject:post_item];
        NSLog(@"含まれてまっせ");
    }
    [tableView reloadData];
}

@end
