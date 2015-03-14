//
//  RecorderSubmitPopupView.h
//  Gocci
//

#import <UIKit/UIKit.h>

@class RecorderSubmitPopupView;

@protocol RecorderSubmitPopupViewDelegate <NSObject>

- (void)recorderSubmitPopupViewOnTwitterShare:(RecorderSubmitPopupView *)view;
- (void)recorderSubmitPopupViewOnFacebookShare:(RecorderSubmitPopupView *)view;
- (void)recorderSubmitPopupViewOnSubmit:(RecorderSubmitPopupView *)view;

@end

typedef void (^RecorderSubmitPopupViewCancelCallback)(void);

/**
 *  投稿画面
 */
@interface RecorderSubmitPopupView : UIView

@property (nonatomic, weak) id<RecorderSubmitPopupViewDelegate> delegate;

/** キャンセルボタン押下時処理 */
@property (nonatomic, copy) RecorderSubmitPopupViewCancelCallback cancelCallback;

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
