//
//  TutorialView.m
//  Gocci
//

#import "TutorialView.h"
#import "TutorialPageView.h"
#import "UIColor+App.h"

@interface TutorialView()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *skipButton;

@end

@implementation TutorialView

+ (instancetype)showTutorialInView:(UIView *)view delegate:(id<TutorialViewDelegate>)tutorialDelegate
{
    TutorialView *tutorialView = [[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil][0];
    tutorialView.tutorialDelegate = tutorialDelegate;
    tutorialView.frame = view.bounds;
    tutorialView.scrollView.frame = view.bounds;
    
    // UIPageControl 見た目の調整
    tutorialView.pageControl.frame = CGRectMake(0.0,
                                                view.frame.size.height - 32.0 - 48.0 - 48.0,
                                                view.frame.size.width,
                                                tutorialView.pageControl.frame.size.height);
    tutorialView.pageControl.currentPageIndicatorTintColor = [UIColor app_tutorialLightGrayColor];
    tutorialView.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    
    // 「Gocci を始める」ボタン 見た目のカスタマイズ
    tutorialView.skipButton.frame = CGRectMake(24.0,
                                               view.frame.size.height - 32.0 - 48.0,
                                               view.frame.size.width - 48.0,
                                               48.0);
    [tutorialView.skipButton setTitleColor:[UIColor app_tutorialDarkGrayColor] forState:UIControlStateNormal];
    [tutorialView.skipButton setTitle:@"Gocci を始める" forState:UIControlStateNormal];
    tutorialView.skipButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
    tutorialView.skipButton.layer.borderColor = [UIColor app_tutorialDarkGrayColor].CGColor;
    tutorialView.skipButton.layer.borderWidth = 1.0;
    tutorialView.skipButton.layer.cornerRadius = 3.0;
    
    // ウォークスルーの各画面
    TutorialPageView *page1 = [TutorialPageView viewWithNibName:@"TutorialPage1"];
    TutorialPageView *page2 = [TutorialPageView viewWithNibName:@"TutorialPage2"];
    TutorialPageView *page3 = [TutorialPageView viewWithNibName:@"TutorialPage1"];
    TutorialPageView *page4 = [TutorialPageView viewWithNibName:@"TutorialPage1"];
    
    CGFloat contentWidth = 0.0;
    for (TutorialPageView *page in @[page1, page2, page3, page4]) {
        page.frame = CGRectMake(contentWidth,
                                0.0,
                                tutorialView.scrollView.frame.size.width,
                                tutorialView.scrollView.frame.size.height);
        [page setup];
        LOG(@"page.frame=%@", NSStringFromCGRect(page.frame));
        [tutorialView.scrollView addSubview:page];
        
        contentWidth += page.frame.size.width;
    }
    
    tutorialView.scrollView.contentSize = CGSizeMake(contentWidth, tutorialView.scrollView.frame.size.height);
    [view addSubview:tutorialView];
    
    return tutorialView;
}

@end
