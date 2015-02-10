//
//  SearchCell.h
//  Gocci
//

#import <UIKit/UIKit.h>

extern NSString * const SearchCellIdentifier;

@class Restaurant;
@class SearchCell;

@protocol SearchCellDelegate <NSObject>

@optional

/**
 *  「地図を見る」タップ時
 *
 *  @param cell
 *  @param index
 */
- (void)searchCell:(SearchCell *)cell shouldShowMapAtIndex:(NSUInteger)index;

/**
 *  「この店舗を詳しく見る」タップ時
 *
 *  @param cell
 *  @param index
 */
- (void)searchCell:(SearchCell *)cell shouldDetailAtIndex:(NSUInteger)index;

@end

/**
 *  検索画面 セル
 */
@interface SearchCell : UITableViewCell

@property (nonatomic, weak) id<SearchCellDelegate> delegate;
@property (nonatomic, readonly) NSUInteger restaurantIndex;

/**
 *  SearchCell を生成
 *
 *  @return 
 */
+ (instancetype)cell;

/**
 *  セルの高さ
 *
 *  @return
 */
+ (CGFloat)cellHeight;

/**
 *  セルの表示を設定
 *
 *  @param restaurant 
 *  @param index      セルに設定するデータ配列のインデックスを保存
 */
- (void)configureWithRestaurant:(Restaurant *)restaurant index:(NSUInteger)index;

@end
