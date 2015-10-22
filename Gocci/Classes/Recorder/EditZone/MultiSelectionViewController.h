//
//  MultiSelectionViewController.h
//  STPopup
//
//  Created by Kevin Lin on 11/10/15.
//  Copyright © 2015 Sth4Me. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiSelectionViewController;

@protocol MultiSelectionViewControllerDelegate <NSObject>

- (void)multiSelectionViewController:(MultiSelectionViewController *)vc didFinishWithSelections:(NSArray *)selections post_param:(NSArray*)post_param;

@end

@interface MultiSelectionViewController : UITableViewController

@property (nonatomic, weak) id<MultiSelectionViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *post_param;
@property (nonatomic, strong) NSArray *defaultSelections;

@end
