//
//  BottomSheetDemoViewController.m
//  STPopup
//
//  Created by Kevin Lin on 11/10/15.
//  Copyright © 2015 Sth4Me. All rights reserved.
//

#import "BottomSheet.h"
#import "MultiSelectionViewController.h"
#import "CommentPopup.h"
#import "STPopup.h"
#import "APIClient.h"
#import "Restaurant.h"
#import "LocationClient.h"

NSString * const BottomSheetRestaurant = @"店名";
NSString * const BottomSheetCategory = @"カテゴリー";
NSString * const BottomSheetValue = @"価格";
NSString * const BottomSheetComment = @"一言";

@interface BottomSheetCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) NSArray *selections;
@end

@implementation BottomSheetCell
{
    NSArray *_buttons;
}

- (void)setSelections:(NSArray *)selections
{
    selections = [selections sortedArrayUsingSelector:@selector(localizedCompare:)];
    _selections = selections;
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.placeholderLabel.hidden = selections.count > 0;
    
    CGFloat buttonX = 15;
    NSMutableArray *buttons = [NSMutableArray new];
    for (NSString *selection in selections) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.layer.cornerRadius = 4;
        button.backgroundColor = [UIColor redColor];
        button.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        [button setTitle:selection forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button sizeToFit];
        button.frame = CGRectMake(buttonX, (self.scrollView.frame.size.height - button.frame.size.height) / 2, button.frame.size.width, button.frame.size.height);
        
        [buttons addObject:button];
        [self.scrollView addSubview:button];
        
        buttonX += button.frame.size.width + 10;
    }
    self.scrollView.contentSize = CGSizeMake(buttonX, self.scrollView.frame.size.height);
    
    _buttons = [NSArray arrayWithArray:buttons];
}

@end

@interface BottomSheet () <MultiSelectionViewControllerDelegate,CommentPopupDelegate>

@end

@implementation BottomSheet
{
    NSArray *_CategorySelections;
    NSArray *_RestnameSelections;
    NSArray *_ValueSelections;
    NSArray *_CommentSelections;
    NSMutableArray *restaurant;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 300);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.height, 300);
    [self _getRestaurant:YES];
}

- (void)multiSelectionViewController:(MultiSelectionViewController *)vc didFinishWithSelections:(NSArray *)selections
{
   if ([vc.title isEqualToString:BottomSheetCategory]) {
        _CategorySelections = selections;
       NSLog(@"selections%@",selections);
    }
    else if ([vc.title isEqualToString:BottomSheetRestaurant]) {
        _RestnameSelections = selections;
    }else if ([vc.title isEqualToString:BottomSheetValue]) {
        _ValueSelections = selections;
    }
    [self.tableView reloadData];
}

- (void)commentPopup:(CommentPopup *)vc didFinishWithSelections:(NSArray *)selections{
    if ([vc.title isEqualToString:BottomSheetComment]) {
        _CommentSelections = selections;
        NSLog(@"selections%@",selections);
    }
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[BottomSheetCell class]]) {
        BottomSheetCell *selectionCell = (BottomSheetCell *)cell;
        selectionCell.selections = [[[[NSArray arrayWithArray:_CategorySelections] arrayByAddingObjectsFromArray:_RestnameSelections] arrayByAddingObjectsFromArray:_ValueSelections ] arrayByAddingObjectsFromArray:_CommentSelections];
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CommentPopup *Comment = (CommentPopup *)segue.destinationViewController;
    Comment.delegate = self;
    MultiSelectionViewController *destinationViewController = (MultiSelectionViewController *)segue.destinationViewController;
    destinationViewController.delegate = self;
    
    if ([segue.identifier isEqualToString:@"Category"]) {
        destinationViewController.title = BottomSheetCategory;
        destinationViewController.items = @[ @"和食", @"洋食", @"中華", @"カレー", @"ラーメン", @"居酒屋" ];
        destinationViewController.defaultSelections = _CategorySelections;
    }
    else if ([segue.identifier isEqualToString:@"Restname"]) {
        destinationViewController.title = BottomSheetRestaurant;
        destinationViewController.items = restaurant;
        destinationViewController.defaultSelections = _RestnameSelections;
    }else if ([segue.identifier isEqualToString:@"Value"]) {
        Comment.title = BottomSheetValue;
        Comment.defaultSelections = _ValueSelections;
    }else if ([segue.identifier isEqualToString:@"Comment"]) {
        Comment.title = BottomSheetComment;
        Comment.defaultSelections = _CommentSelections;
//[self.popupController pushViewController:[CommentPopup new] animated:YES];
    }
}

/**
 *  初回のレストラン一覧を取得
 *
 *  @param coordinate 検索する緯度・軽度
 */
- (void)_getRestaurant:(BOOL)usingLocationCache{

    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
   {
    [APIClient Near:coordinate.latitude longitude:coordinate.longitude handler:^(id result, NSUInteger code, NSError *error)
     {
         
         NSLog(@"before recorder result:%@",result);
         
          restaurant = [NSMutableArray arrayWithCapacity:0];
         
         for (NSDictionary *dict in (NSArray *)result) {
             NSDictionary *restnameGet = [dict objectForKey:@"restname"];
             [restaurant addObject:restnameGet];
         }
         
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }];
    };

    // 位置情報キャッシュを使う場合で、位置情報キャッシュが存在する場合、
    // キャッシュされた位置情報を利用して API からデータを取得する
    CLLocation *cachedLocation = [LocationClient sharedClient].cachedLocation;
    if (usingLocationCache && cachedLocation != nil) {
        fetchAPI(cachedLocation.coordinate);
        NSLog(@"ここ通ったよ2");
        return;
    }
    
    // 位置情報キャッシュを使わない、あるいはキャッシュが存在しない場合、
    // 位置情報を取得してから API へアクセスする
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
     {
         NSLog(@"ここ通ったよ3");
         LOG(@"location=%@, error=%@", location, error);
         
         if (error) {
             // 位置情報の取得に失敗
             // TODO: アラート等を掲出
             return;
         }
         fetchAPI(location.coordinate);
         
     }];


}

@end
