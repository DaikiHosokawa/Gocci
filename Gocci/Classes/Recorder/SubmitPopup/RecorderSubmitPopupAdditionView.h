//
//  RecorderSubmitPopupView.h
//  Gocci
//

#import <UIKit/UIKit.h>

@class RecorderSubmitPopupAdditionView;

@protocol RecorderSubmitPopupAdditionViewDelegate <NSObject>
@optional
- (void)recorderSubmitPopupAdditionViewOnTwitterShare:(RecorderSubmitPopupAdditionView *)view;
- (void)recorderSubmitPopupAdditionViewOnFacebookShare:(RecorderSubmitPopupAdditionView *)view;
- (void)recorderSubmitPopupAdditionViewOnSubmit:(RecorderSubmitPopupAdditionView *)view;

@end

typedef void (^RecorderSubmitPopupAdditionViewCancelCallback)(void);

/**
 *  投稿画面
 */
@interface RecorderSubmitPopupAdditionView : UIView

@property (nonatomic, weak) id<RecorderSubmitPopupAdditionViewDelegate> delegate;

/** キャンセルボタン押下時処理 */
@property (nonatomic, copy) RecorderSubmitPopupAdditionViewCancelCallback cancelCallback;

@property (nonatomic, retain) NSMutableArray *restname;

/**
 *  View を生成
 *
 *  @return
 */
+ (instancetype)view;

/**
 *  画面を表示
 *
 *  @param view
 */
- (void)showInView:(UIView *)view;

/**
 *  画面を消去
 */
- (void)dismiss;

@end
