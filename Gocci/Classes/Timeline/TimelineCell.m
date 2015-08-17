//
//  Sample2TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "TimelineCell.h"
#import "TimelinePost.h"
#import "UIView+DropShadow.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Dummy.h"

#define THUMBNAIL_VIEW_MARGIN 8.0

NSString * const TimelineCellIdentifier = @"TimelineCell";

@interface TimelineCell()

@property (nonatomic, weak) IBOutlet UIView *background;
@property (nonatomic, weak) IBOutlet UIImageView *avaterImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;


@property (nonatomic, weak) IBOutlet UIView *restaurantView;
@property (nonatomic, weak) IBOutlet UIImageView *restaurantImageView;
@property (nonatomic, weak) IBOutlet UILabel *restaurantNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *restaurantAddressLabel;

@property (nonatomic, weak) IBOutlet UIView *likeView;
@property (nonatomic, weak) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cheerView;

@property (nonatomic, weak) IBOutlet UIView *commentView;
@property (nonatomic, weak) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantNaviview;
@property (weak, nonatomic) IBOutlet UIImageView *startPlaying;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewHeightConstraint;

@property (nonatomic) NSString *pushed_at;
@property (nonatomic) NSInteger flag;

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *rest_id;
@property (nonatomic, strong) NSString *user_id;
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

@property (weak, nonatomic) IBOutlet UIImageView *tagA;
@property (weak, nonatomic) IBOutlet UIImageView *tagB;
@property (weak, nonatomic) IBOutlet UIImageView *tagC;
@property (weak, nonatomic) IBOutlet UIImageView *medal;
@property (weak, nonatomic) IBOutlet UILabel *tagBLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagALabel;
@property (weak, nonatomic) IBOutlet UILabel *tagCLabel;

@end

@implementation TimelineCell

#pragma mark - Initialize

+ (instancetype)cell
{
    return [[NSBundle mainBundle] loadNibNamed:@"TimelineCell" owner:self options:nil][0];
}


#pragma mark - Action


- (void)tapthumb:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapthumb:)]) {
        [self.delegate timelineCell:self didTapthumb:self.thumbnailView];
    }
}

- (void)tapNameLabel:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapUserName:)]) {
        [self.delegate timelineCell:self didTapUserName:self.user_id];
    }
}

- (void)tapAvaterImageView:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapPicture:)]) {
        [self.delegate timelineCell:self didTapPicture:self.user_id];
    }
}

- (void)tapRestautant:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapRestaurant:)]) {
        [self.delegate timelineCell:self didTapRestaurant:self.rest_id];
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

#pragma mark - Public Method

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost
{
    [self.background dropShadow];
    
    self.postID = timelinePost.postID;
    self.username = timelinePost.userName;
    self.userspicture = timelinePost.picture;
    self.restname = timelinePost.restname;
    self.locality = timelinePost.locality;
    self.homepage = timelinePost.homepage;
    self.tell = timelinePost.tel;
    self.category = timelinePost.category;
    self.lat = timelinePost.lat;
    self.lon = timelinePost.lon;
    self.total_cheer = timelinePost.totalCheer;
    self.want_tag = timelinePost.want_flag;
    self.rest_id = timelinePost.rest_id;
    self.user_id = timelinePost.userID;
    
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
    [self.avaterImageView sd_setImageWithURL:[NSURL URLWithString:timelinePost.picture]
                            placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // ユーザ名
    self.userNameLabel.text = timelinePost.userName;
    
    // TODO: 時間
    self.timeLabel.text = timelinePost.timelabel;
    
    // サムネイル画像
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:timelinePost.thumbnail]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // TODO: 店舗サムネイル画像
    self.restaurantImageView.image = [UIImage imageNamed:@"ic_userpicture.png"];
    
    // 店舗名
    self.restaurantNameLabel.text = timelinePost.restname;
    
    // 店舗住所
    self.restaurantAddressLabel.text = timelinePost.locality;
    
    
    if ([timelinePost.comment isEqualToString:@"none"]) {
        self.commentLabel.text = @"";
    }
    else{
        self.commentLabel.text = timelinePost.comment;
    }
    
    // Like 数
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", @(timelinePost.goodNum)];
    
    // Comment 数
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@", @(timelinePost.commentNum)];
    
    //いいねしているかどうか
    self.pushed_at = timelinePost.pushed_at;
    
    
    //自分がフォローしているかどうか
    self.flag = timelinePost.flag;
    
    
    //tagB
    if ([timelinePost.tagB isEqualToString:@"にぎやか"]) {
        self.tagBLabel.text = timelinePost.tagB;
    } else if ([timelinePost.tagB isEqualToString:@"ゆったり"]) {
        self.tagBLabel.text = timelinePost.tagB;
    } else if([timelinePost.tagB isEqualToString:@"none"]) {
        self.tagBLabel.text = @"タグなし";
    }else{
        self.tagBLabel.text = @"タグなし";
    }
    
    //tagA
    if ([timelinePost.tagA isEqualToString:@"和風"]) {
        self.tagALabel.text = timelinePost.tagA;
        
    } else if ([timelinePost.tagA isEqualToString:@"洋風"]) {
        self.tagALabel.text = timelinePost.tagA;
    } else if ([timelinePost.tagA isEqualToString:@"中華"]) {
        self.tagALabel.text = timelinePost.tagA;
    } else if ([timelinePost.tagA isEqualToString:@"カレー"]) {
        self.tagALabel.text = timelinePost.tagA;
    } else if ([timelinePost.tagA isEqualToString:@"カフェ"]) {
        self.tagALabel.text = timelinePost.tagA;
    } else if ([timelinePost.tagA isEqualToString:@"ラーメン"]) {
        self.tagALabel.text = timelinePost.tagA;
    }else if ([timelinePost.tagA isEqualToString:@"居酒屋"]) {
        self.tagALabel.text = timelinePost.tagA;
    } else if ([timelinePost.tagA isEqualToString:@"その他"]) {
        self.tagALabel.text = timelinePost.tagA;
    } else if ([timelinePost.tagA isEqualToString:@"none"]) {
        self.tagALabel.text = @"タグなし";
    }else{
        self.tagALabel.text = @"タグなし";
    }
    
    if([timelinePost.tagC isEqualToString:@"0"]){
        self.tagCLabel.text = @"タグなし";
    }
    else if ([timelinePost.tagC isEqualToString:@"none"]){
        self.tagCLabel.text = @"タグなし";
    }else {
        NSString *str3 = [NSString stringWithFormat: @"%@円",timelinePost.tagC];
        self.tagCLabel.text = str3;
    }
    
    NSString *string = [NSString stringWithFormat:@"%@", self.pushed_at];
    if ([string isEqualToString:@"0"])
    {
        UIImage *img = [UIImage imageNamed:@"gocci_new.png"];
        [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 0;
        
    }else{
        UIImage *img = [UIImage imageNamed:@"gocci_new_selected.png"];
        [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 1;
    }
    
    //応援画像
    /*
     if(timelinePost.cheernum > 10){
     self.medal.image = [UIImage imageNamed:@"金.png"];
     }else if(timelinePost.cheernum > 5){
     self.medal.image = [UIImage imageNamed:@"銀.png"];
     }else if(timelinePost.cheernum > 3) {
     self.medal.image = [UIImage imageNamed:@"銅.png"];
     }else if(timelinePost.commentNum > 0) {
     //self.image.hidden = YES;
     }
     */
    
    //self.cheerView.image = [UIImage imageNamed:@"ic_userpicture.png"];
    
    // タップイベント
    [self _assignTapAction:@selector(tapNameLabel:) view:self.userNameLabel];
    [self _assignTapAction:@selector(tapAvaterImageView:) view:self.avaterImageView];
    [self _assignTapAction:@selector(tapRestautant:) view:self.restaurantImageView];
    [self _assignTapAction:@selector(tapRestautant:) view:self.restaurantAddressLabel];
    [self _assignTapAction:@selector(tapRestautant:) view:self.restaurantNameLabel];
    [self _assignTapAction:@selector(tapNavi:) view:self.restaurantNaviview];
    [self _assignTapAction:@selector(tapLike:) view:self.likeView];
    //テスト
    [self _assignTapAction:@selector(tapthumb:) view:self.thumbnailView];
    [self _assignTapAction:@selector(tapComment:) view:self.commentView];
    [self _assignTapAction:@selector(tapViolate:) view:self.ViolateView];
}

+ (CGFloat)cellHeightWithTimelinePost:(TimelinePost *)post
{
    TimelineCell *cell = [TimelineCell cell];
    [cell configureWithTimelinePost:post];
    
    return cell.thumbnailViewTopConstraint.constant + cell.thumbnailView.frame.size.height + cell.thumbnailViewBottomConstraint.constant;
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

@end
