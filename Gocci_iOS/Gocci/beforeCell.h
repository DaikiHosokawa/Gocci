//
//  beforeCell.h
//  Gocci
//

#import <UIKit/UIKit.h>

extern NSString * const beforeCellIdentifier;

@class Restaurant;
@class beforeCell;

@protocol beforeCellDelegate <NSObject>

@optional

/**
 *  「地図を見る」タップ時
 *
 *  @param cell
 *  @param index
 */
- (void)beforeCell:(beforeCell *)cell shouldShowMapAtIndex:(NSUInteger)index;

/**
 *  「この店舗を詳しく見る」タップ時
 *
 *  @param cell
 *  @param index
 */
- (void)beforeCell:(beforeCell *)cell shouldDetailAtIndex:(NSUInteger)index;

@end

/**
 *  検索画面 セル
 */
@interface beforeCell : UITableViewCell

@property (nonatomic, weak) id<beforeCellDelegate> delegate;
@property (nonatomic, readonly) NSUInteger restaurantIndex;

/**
 *  beforeCell を生成
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
