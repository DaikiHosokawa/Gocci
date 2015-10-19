//
//  SCScrollPageView.m
//  Gocci
//
//  Created by INASE on 2015/05/10.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "SCScrollPageView.h"

#import "SCFirstView.h"
#import "SCSecondView.h"


@interface SCScrollPageView()
{
	UIScrollView *scrollviewPage;
	UIPageControl *pager;
}

@end

@implementation SCScrollPageView

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
	}
	return self;
}

-(void)showInView:(UIView*)superview first:(SCFirstView*)viewfirst second:(SCSecondView*)viewsecond
{
	[superview addSubview:self];

	//スクロールビュー
	CGFloat width_page = self.frame.size.width;
	CGFloat height_page = self.frame.size.height;
	
	scrollviewPage = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width_page, height_page)];
	scrollviewPage.delegate = self;
	scrollviewPage.contentSize = CGSizeMake(width_page, height_page);
	scrollviewPage.pagingEnabled = YES;
	scrollviewPage.showsHorizontalScrollIndicator = NO;
	scrollviewPage.showsVerticalScrollIndicator = NO;
	//scrollviewPage.scrollsToTop = NO;
	scrollviewPage.bounces = NO;
	//pageingScrollView.backgroundColor = [UIColor lightGrayColor];
	[self addSubview:scrollviewPage];

	[viewfirst showInView:scrollviewPage];	//画面サイズから場合分け

	/*
    pager = [[UIPageControl alloc] initWithFrame:CGRectMake(0,y_page, width_page,height_pc)];
	pager.backgroundColor = [UIColor whiteColor];
    pager.pageIndicatorTintColor = [UIColor grayColor];
    pager.currentPageIndicatorTintColor = [UIColor blackColor];
	pager.numberOfPages = 2;		// ページ数を指定
	pager.currentPage = 0;		// ページ番号は0ページを指定(1にするとこの場合真ん中のページが指定される)
	pager.hidesForSinglePage = NO;		// ページが1ページのみの場合は現在ページを示す点を表示しない
	*/
     pager.userInteractionEnabled = NO;
     
	[self addSubview:pager];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// UIScrollViewのページ切替時イベント:UIPageControlの現在ページを切り替える処理
	pager.currentPage = scrollviewPage.contentOffset.x / self.frame.size.width;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
