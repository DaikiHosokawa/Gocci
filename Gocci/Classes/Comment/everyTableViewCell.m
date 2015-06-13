//
//  everyTableViewCell.m
//  Gocci
//
//  Created by デザミ on 2015/06/12.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "everyTableViewCell.h"

//#import "TimelinePost.h"
#import "EveryPost.h"
#import "UIView+DropShadow.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Dummy.h"

#define THUMBNAIL_VIEW_MARGIN 8.0

NSString * const EveryCellIdentifier = @"everyTableViewCell";

@interface everyTableViewCell()
{
	int flash_on;

}

@property (weak, nonatomic) IBOutlet UIView *background;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avaterImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (weak, nonatomic) IBOutlet UIView *restaurantView;
@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tagA;
@property (weak, nonatomic) IBOutlet UIImageView *tagB;
@property (weak, nonatomic) IBOutlet UIImageView *tagC;
@property (weak, nonatomic) IBOutlet UILabel *tagALabel;
@property (weak, nonatomic) IBOutlet UILabel *tagBLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagCLabel;

@property (weak, nonatomic) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewHeightConstraint;

@property (nonatomic, weak) UIImageView *restaurantImageView;
@property (nonatomic, weak) UILabel *restaurantAddressLabel;
@property (weak, nonatomic) UIImageView *restaurantNaviview;

//@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
//@property (weak, nonatomic) IBOutlet UIImageView *ViolateView;

@property (nonatomic) NSString *pushed_at;
@property (nonatomic) NSInteger flag;

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userspicture;
@property (nonatomic, strong) NSString *restname;
@property (nonatomic, strong) NSString *locality;
@property (nonatomic, strong) NSString *tell;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, strong) NSString *total_cheer;
@property (nonatomic, strong) NSString *want_tag;

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;

@end

@implementation everyTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Private Methods
/**
 *  View にタップイベントを設定
 *
 *  @param selector タップイベント時に呼び出されるメソッド
 *  @param view     設定先の View
 */
- (void)_assignTapAction:(SEL)selector view:(UIView *)view
{
	for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
		[view removeGestureRecognizer:recognizer];
	}
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
																		  action:selector];
	view.userInteractionEnabled = YES;
	[view addGestureRecognizer:tap];
}

#pragma mark - Public Method
- (void)configureWithTimelinePost:(EveryPost *)everyPost
{
	[self.background dropShadow];
	
	self.postID = everyPost.post_id;
	self.username = everyPost.username;
	self.userspicture = everyPost.profile_img;
	self.restname = everyPost.restname;
	self.category = everyPost.category;
	
	// ユーザアイコンを円形に
	self.avaterImageView.layer.cornerRadius = self.avaterImageView.frame.size.width / 2.0;
	self.avaterImageView.clipsToBounds = YES;
	
	// 動画サムネイルのサイズ調整
	// 一辺の長さが (画面の横幅 - マージン) の正方形とする
	CGFloat thumbnailWidth = [UIScreen mainScreen].bounds.size.width - (THUMBNAIL_VIEW_MARGIN * 2);
	self.thumbnailViewWidthConstraint.constant = thumbnailWidth;
	self.thumbnailViewHeightConstraint.constant = thumbnailWidth;
	self.thumbnailView.frame = CGRectMake(THUMBNAIL_VIEW_MARGIN,
										  self.thumbnailView.frame.origin.y,
										  thumbnailWidth, thumbnailWidth);
	
	// ユーザ画像
	[self.avaterImageView sd_setImageWithURL:[NSURL URLWithString:everyPost.profile_img]
							placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
	
	// ユーザ名
	self.userNameLabel.text = everyPost.username;
	
	// TODO: 時間
	self.timeLabel.text = everyPost.post_date;
	
	// サムネイル画像
	[self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:everyPost.thumbnail]
						  placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
	
	// 店舗サムネイル画像
	self.restaurantImageView.image = [UIImage imageNamed:@"ic_userpicture.png"];
	
	// 店舗名
	self.restaurantNameLabel.text = everyPost.restname;
	
	//Memo
	self.commentLabel.text = everyPost.memo;
	
	// Like 数
	self.likeCountLabel.text = [NSString stringWithFormat:@"%@", @(everyPost.like_num)];
	
	// Comment 数
	self.commentCountLabel.text = [NSString stringWithFormat:@"%@", @(everyPost.comment_num)];
	
	//Category
	if ([everyPost.category isEqualToString:@"和風"]) {
		self.tagALabel.text = everyPost.category;
		
	} else if ([everyPost.category isEqualToString:@"洋風"]) {
		self.tagALabel.text = everyPost.category;
	} else if ([everyPost.category isEqualToString:@"中華"]) {
		self.tagALabel.text = everyPost.category;
	} else if ([everyPost.category isEqualToString:@"カレー"]) {
		self.tagALabel.text = everyPost.category;
	} else if ([everyPost.category isEqualToString:@"カフェ"]) {
		self.tagALabel.text = everyPost.category;
	} else if ([everyPost.category isEqualToString:@"ラーメン"]) {
		self.tagALabel.text = everyPost.category;
	} else if ([everyPost.category isEqualToString:@"居酒屋"]) {
		self.tagALabel.text = everyPost.category;
	} else if ([everyPost.category isEqualToString:@"その他"]) {
		self.tagALabel.text = everyPost.category;
	} else if ([everyPost.category isEqualToString:@"none"]) {
		self.tagALabel.text = @"タグなし";
	} else{
		self.tagALabel.text = @"タグなし";
	}
	
	//Tag
	if ([everyPost.tag isEqualToString:@"にぎやか"]) {
		self.tagBLabel.text = everyPost.tag;
	} else if ([everyPost.tag isEqualToString:@"ゆったり"]) {
		self.tagBLabel.text = everyPost.tag;
	} else if([everyPost.tag isEqualToString:@"none"]) {
		self.tagBLabel.text = @"タグなし";
	} else{
		self.tagBLabel.text = @"タグなし";
	}
	
	//Value
	if([everyPost.value isEqualToString:@"0"]){
		self.tagCLabel.text = @"タグなし";
	}
	else if ([everyPost.value isEqualToString:@"none"]){
		self.tagCLabel.text = @"タグなし";
	}else {
		NSString *str3 = [NSString stringWithFormat: @"%@円",everyPost.value];
		self.tagCLabel.text = str3;
	}
	
//	// タップイベント
//	[self _assignTapAction:@selector(tapNameLabel:) view:self.userNameLabel];
//	[self _assignTapAction:@selector(tapAvaterImageView:) view:self.avaterImageView];
//	[self _assignTapAction:@selector(tapRestautant:) view:self.restaurantImageView];
//	[self _assignTapAction:@selector(tapRestautant:) view:self.restaurantAddressLabel];
//	[self _assignTapAction:@selector(tapRestautant:) view:self.restaurantNameLabel];
//	[self _assignTapAction:@selector(tapNavi:) view:self.restaurantNaviview];
//	[self _assignTapAction:@selector(tapLike:) view:self.likeView];
//	//テスト
//	[self _assignTapAction:@selector(tapthumb:) view:self.thumbnailView];
//	[self _assignTapAction:@selector(tapComment:) view:self.commentView];
//	[self _assignTapAction:@selector(tapViolate:) view:self.ViolateView];
}

+ (CGFloat)cellHeightWithTimelinePost:(EveryPost *)post
{
	everyTableViewCell *cell = [everyTableViewCell cell];
	[cell configureWithTimelinePost:post];

//	NSLog(@"ViewHeight:%f",cell.frame.size.height);
//
//	NSLog(@"Top:%f",cell.thumbnailViewTopConstraint.constant);
//	NSLog(@"Height:%f",cell.thumbnailView.frame.size.height);
//	NSLog(@"Bottom:%f",cell.thumbnailViewBottomConstraint.constant);
	
	return cell.thumbnailViewTopConstraint.constant + cell.thumbnailView.frame.size.height + cell.thumbnailViewBottomConstraint.constant;
}

#pragma mark - Action

- (void)tapNameLabel:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapNameWithUserName:picture:flag:)]) {
		[self.delegate timelineCell:self didTapNameWithUserName:self.username picture:_userspicture flag:_flag];
	}
}

- (void)tapthumb:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapthumb:)]) {
		[self.delegate timelineCell:self didTapthumb:self.thumbnailView];
		//self.startPlaying.hidden = YES;
	}
}

- (void)tapAvaterImageView:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapNameWithUserPicture:name:flag:)]) {
		[self.delegate timelineCell:self didTapNameWithUserPicture:self.userspicture name:_username flag:_flag];
	}
}

- (void)tapRestautant:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapRestaurant:locality:tel:homepage:category:lon:lat:total_cheer:want_tag:)]) {
		[self.delegate timelineCell:self didTapRestaurant:self.restname locality:self.locality tel:self.tell homepage:self.homepage category:self.category lon:self.lon lat:self.lat total_cheer:self.total_cheer want_tag:self.want_tag];
	}
}

- (void)tapLike:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapLikeButtonWithPostID:)]) {
		
		if(flash_on == 0 ){
			UIImage *img = [UIImage imageNamed:@"gocci_new_selected.png"];
			[_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
			flash_on = 1;
			int plus1 = self.likeCountLabel.text.floatValue+1;
			[_likeCountLabel setText:[NSString stringWithFormat:@"%d", plus1]];
			//_likeCountLabel.text.floatValue == a;
			//スイッチオフに戻った場合の処理を記述
			NSLog(@"button selected");
			dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
			dispatch_sync(globalQueue, ^{
				[self.delegate timelineCell:self didTapLikeButtonWithPostID:self.postID];
			});
		}else{
			
			UIImage *img = [UIImage imageNamed:@"gocci_new.png"];
			[_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
			int minus1 = self.likeCountLabel.text.floatValue-1;
			[_likeCountLabel setText:[NSString stringWithFormat:@"%d", minus1]];
			flash_on = 0;
			//スイッチオン時の処理を記述できます
			NSLog(@"button not selected");
		}
		
	}
}


- (void)tapNavi:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapNaviWithLocality:)]) {
		[self.delegate timelineCell:self didTapNaviWithLocality:self.locality];
	}
}

- (void)tapComment:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapCommentButtonWithPostID:)]) {
		[self.delegate timelineCell:self didTapCommentButtonWithPostID:self.postID];
	}
}


- (void)tapViolate:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapViolateButtonWithPostID:)]) {
		[self.delegate timelineCell:self didTapViolateButtonWithPostID:self.postID];
	}
}

- (void)onDeleteButton:(UITapGestureRecognizer *)recognizer
{
	if ([self.delegate respondsToSelector:@selector(timelineCell:didTapDeleteWithPostID:)]) {
		[self.delegate timelineCell:self didTapDeleteWithPostID:self.postID];
	}
}

#pragma mark - Initialize
+ (instancetype)cell
{
	return [[NSBundle mainBundle] loadNibNamed:EveryCellIdentifier owner:self options:nil][0];
}

@end
