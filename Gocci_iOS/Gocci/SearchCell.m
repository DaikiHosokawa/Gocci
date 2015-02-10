//
//  SearchCell.m
//  Gocci
//

#import "SearchCell.h"
#import "Restaurant.h"
#import "UIView+DropShadow.h"

NSString * const SearchCellIdentifier = @"SearchCell";

@interface SearchCell()

@property (nonatomic, weak) IBOutlet UIView *background;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *restaurantNameLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *mapLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@property (nonatomic) NSUInteger restaurantIndex;

@end

@implementation SearchCell

#pragma mark - Initialize

+ (instancetype)cell
{
    return [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil][0];
}


#pragma mark - Action

- (void)tapMapLabel:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(searchCell:shouldShowMapAtIndex:)]) {
        [self.delegate searchCell:self shouldShowMapAtIndex:self.restaurantIndex];
    }
}

- (void)tapDetailLabel:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(searchCell:shouldDetailAtIndex:)]) {
        [self.delegate searchCell:self shouldDetailAtIndex:self.restaurantIndex];
    }
}


#pragma mark - Public Methods

+ (CGFloat)cellHeight
{
    return [SearchCell cell].frame.size.height;
}

- (void)configureWithRestaurant:(Restaurant *)restaurant index:(NSUInteger)index;
{
    self.restaurantIndex = index;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.background dropShadow];
    
    // 「地図を見る」タップイベント
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMapLabel:)];
    [self.mapLabel addGestureRecognizer:tapMap];
    self.mapLabel.userInteractionEnabled = YES;
    
    // 「この店舗の詳しく見る」タップイベント
    UITapGestureRecognizer *tapDetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetailLabel:)];
    [self.detailLabel addGestureRecognizer:tapDetail];
    self.detailLabel.userInteractionEnabled = YES;

    // 情報を表示
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", (restaurant.distance / 1000.0)];
    self.restaurantNameLabel.text = restaurant.restname;
}

@end
