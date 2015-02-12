//
//  TutorialView.h
//  Gocci
//

#import <UIKit/UIKit.h>

@class TutorialView;

@protocol TutorialViewDelegate <NSObject>

- (void)tutorialDidFinish:(TutorialView *)view;

@end

/**
 *  チュートリアル画面
 */
@interface TutorialView : UIView

@property (nonatomic, weak) id<TutorialViewDelegate> tutorialDelegate;

/**
 *  チュートリアル画面を表示
 *
 *  @param view             表示元の UIView
 *  @param tutorialDelegate
 *
 *  @return 
 */
+ (instancetype)showTutorialInView:(UIView *)view delegate:(id<TutorialViewDelegate>)tutorialDelegate;

@end
