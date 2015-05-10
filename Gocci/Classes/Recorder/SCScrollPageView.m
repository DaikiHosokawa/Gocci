//
//  SCScrollPageView.m
//  Gocci
//
//  Created by デザミ on 2015/05/10.
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
	scrollviewPage.contentSize = CGSizeMake(width_page * 2, height_page);
	scrollviewPage.pagingEnabled = YES;
	scrollviewPage.showsHorizontalScrollIndicator = NO;
	scrollviewPage.showsVerticalScrollIndicator = NO;
	scrollviewPage.scrollsToTop = NO;
	scrollviewPage.bounces = NO;
	//pageingScrollView.backgroundColor = [UIColor lightGrayColor];
	[self addSubview:scrollviewPage];

	[viewfirst showInView:scrollviewPage];
	[viewsecond showInView:scrollviewPage offset:CGPointMake(width_page, 0) back:0];

	//画面サイズから場合分け
	CGRect rect = [UIScreen mainScreen].bounds;
	CGFloat y_page = 35 + 100;
	//画面サイズから場合分け
	if (rect.size.height == 480) {
		//3.5inch
		y_page = 27 + 90;
	}
	else if (rect.size.height == 667) {
		//4.7inch
		y_page = 50 + 100;
	}
	else if (rect.size.height == 736) {
		//5.5inch
		y_page = 60 + 100;
	}
	//CGFloat origin_y_scroll = self.scrollviewPage.frame.origin.y;
	//y_page += origin_y_scroll;
	
	// ページコントロール
	// ページングスクロールビューの下にページコントロールを配置
	CGFloat height_pc = 20;
	pager = [[UIPageControl alloc] initWithFrame:CGRectMake(0,y_page, width_page,height_pc)];
	//pager.backgroundColor = [UIColor blackColor];
	pager.numberOfPages = 2;		// ページ数を指定
	pager.currentPage = 0;		// ページ番号は0ページを指定(1にするとこの場合真ん中のページが指定される)
	pager.hidesForSinglePage = NO;		// ページが1ページのみの場合は現在ページを示す点を表示しない
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
