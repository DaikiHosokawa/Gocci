//
//  TutorialView.m
//  Gocci
//

#import "TutorialView.h"
#import "TutorialPageView.h"
#import "UIColor+App.h"

@interface TutorialView()
<UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *startButton;

@end

@implementation TutorialView

+ (instancetype)showInView:(UIView *)view delegate:(id<TutorialViewDelegate>)tutorialDelegate
{
    TutorialView *tutorialView = [[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil][0];
    tutorialView.tutorialDelegate = tutorialDelegate;
    tutorialView.frame = view.bounds;
    tutorialView.scrollView.frame = view.bounds;
    tutorialView.scrollView.delegate = tutorialView;
    
    // UIPageControl 見た目の調整
    tutorialView.pageControl.frame = CGRectMake(0.0,
                                                view.frame.size.height - 32.0 - 48.0 - 48.0,
                                                view.frame.size.width,
                                                tutorialView.pageControl.frame.size.height);
    tutorialView.pageControl.currentPageIndicatorTintColor = [UIColor app_tutorialLightGrayColor];
    tutorialView.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    
    /*
    // 「Gocci を始める」ボタン 見た目のカスタマイズ
    tutorialView.startButton.frame = CGRectMake(24.0,
                                               view.frame.size.height - 32.0 - 48.0,
                                               view.frame.size.width - 48.0,
                                               48.0);
    [tutorialView.startButton setTitleColor:[UIColor app_tutorialDarkGrayColor] forState:UIControlStateNormal];
    [tutorialView.startButton setTitle:@"Gocci を始める" forState:UIControlStateNormal];
    tutorialView.startButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
    tutorialView.startButton.layer.borderColor = [UIColor app_tutorialDarkGrayColor].CGColor;
    tutorialView.startButton.layer.borderWidth = 1.0;
    tutorialView.startButton.layer.cornerRadius = 3.0;
    */
    
    // ウォークスルーの各画面
    TutorialPageView *page1 = [TutorialPageView viewWithNibName:@"TutorialPage1"];
    TutorialPageView *page2 = [TutorialPageView viewWithNibName:@"TutorialPage2"];
    TutorialPageView *page3 = [TutorialPageView viewWithNibName:@"TutorialPage3"];
   // TutorialPageView *page4 = [TutorialPageView viewWithNibName:@"TutorialPage4"];
    
    CGFloat contentWidth = 0.0;
    for (TutorialPageView *page in @[page1, page2,page3]) {
        page.frame = CGRectMake(contentWidth,
                                0.0,
                                tutorialView.scrollView.frame.size.width,
                                tutorialView.pageControl.frame.origin.y);
       [page setup];
        LOG(@"page.frame=%@", NSStringFromCGRect(page.frame));
        [tutorialView.scrollView addSubview:page];
        
        contentWidth += page.frame.size.width;
    }
    
    tutorialView.scrollView.contentSize = CGSizeMake(contentWidth, tutorialView.scrollView.frame.size.height);
    [view addSubview:tutorialView];
    
    // デフォルトの通知センターを取得する
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // 通知センターに通知要求を登録する
    // この例だと、通知センターに"Tuchi"という名前の通知がされた時に、
    // hogeメソッドを呼び出すという通知要求の登録を行っている。
    [nc addObserver:self selector:@selector(hoge:) name:@"Tuchi" object:nil];
    
    return tutorialView;
}

- (void)dismiss
{
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^{
                         weakSelf.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [weakSelf removeFromSuperview];
                     }];
}


#pragma mark - Action

/**
 *  「Gocci をはじめる」ボタン
 *
 *  @param sender 
 */
- (IBAction)onStartButton:(id)sender
{
    //これはTutorialViewのtutorialDidFinishを呼ぶ(SingupとTimeline遷移の時はすべてこれ)
    if ([self.tutorialDelegate respondsToSelector:@selector(tutorialDidFinish:)]) {
        [self.tutorialDelegate tutorialDidFinish:self];
    }
}

// 通知と値を受けるhogeメソッド
-(void)hoge{
    //これはTutorialViewのtutorialDidFinishを呼ぶ(SingupとTimeline遷移の時はすべてこれ)
    NSLog(@"ここは呼ばれてる");
    if ([self.tutorialDelegate respondsToSelector:@selector(goSNS:)]) {
        [self.tutorialDelegate goSNS:self];
    }
    
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = [self _currentPageIndex:scrollView];
}


#pragma mark - Private Method

/**
 *  ScrollView の現在の位置からページ番号を取得
 *
 *  @param scrollView
 *
 *  @return
 */
- (NSUInteger)_currentPageIndex:(UIScrollView*)scrollView
{
    CGFloat width = CGRectGetWidth(scrollView.frame);
    NSInteger maxPageIndex = 3;
    CGFloat positionX = scrollView.contentOffset.x;
    CGFloat paging = round(positionX / width);

    paging = (paging >= 0.0) ? paging : 0.0;
    paging = (paging <= maxPageIndex) ? paging : maxPageIndex;
    
    return (NSUInteger)paging;
}

@end
