//
//  beforeCell.m
//  Gocci
//

#import "beforeCell.h"
#import "Restaurant.h"
#import "UIView+DropShadow.h"

NSString * const beforeCellIdentifier = @"beforeCell";

@interface beforeCell()

@property (nonatomic, weak) IBOutlet UIView *background;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *restaurantNameLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *mapLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UILabel *restaurantLabel;

@property (nonatomic) NSUInteger restaurantIndex;

@end

@implementation beforeCell

#pragma mark - Initialize

+ (instancetype)cell
{
    return [[NSBundle mainBundle] loadNibNamed:@"beforeCell" owner:self options:nil][0];
}


#pragma mark - Action

- (void)tapMapLabel:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(beforeCell:shouldShowMapAtIndex:)]) {
        [self.delegate beforeCell:self shouldShowMapAtIndex:self.restaurantIndex];
    }
}

- (void)tapDetailLabel:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(beforeCell:shouldDetailAtIndex:)]) {
        [self.delegate beforeCell:self shouldDetailAtIndex:self.restaurantIndex];
    }
}

- (void)tapRestaurantLabel:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(beforeCell:shouldDetailAtIndex2:)]) {
        [self.delegate beforeCell:self shouldDetailAtIndex2:self.restaurantIndex];
    }
}


#pragma mark - Public Methods

+ (CGFloat)cellHeight
{
    return 190;
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
    
    // 店名タップイベント
    UITapGestureRecognizer *tapRestaurant = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRestaurantLabel:)];
    [self.restaurantLabel addGestureRecognizer:tapRestaurant];
    self.restaurantLabel.userInteractionEnabled = YES;
    
    // 情報を表示
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", (restaurant.distance / 1000.0)];
    self.restaurantNameLabel.text = restaurant.restname;
    
    // 店舗サムネイルの表示
    // TODO: API から取得した画像を表示
    for (UIView *v in self.scrollView.subviews) {
        [v removeFromSuperview];
    }
    
    CGFloat thumbnailMargin = 8.0;
    CGSize thumbnailSize = CGSizeMake(self.scrollView.frame.size.height - thumbnailMargin * 2,
                                      self.scrollView.frame.size.height - thumbnailMargin * 2);
    for (NSUInteger i=0; i<10; i++) {
        UIImageView *thumbnail = [UIImageView new];
        thumbnail.frame = CGRectMake(thumbnailMargin + (thumbnailMargin + thumbnailSize.width) * i,
                                     thumbnailMargin,
                                     thumbnailSize.width,
                                     thumbnailSize.height);
        thumbnail.image = [UIImage imageNamed:@"restaurant_placeholder"];
        [self.scrollView addSubview:thumbnail];
    }
    
    self.scrollView.contentSize = CGSizeMake(thumbnailMargin + (thumbnailMargin + thumbnailSize.width) * 10,
                                             self.scrollView.frame.size.height);
}

@end
