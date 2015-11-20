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
	scrollviewPage.bounces = NO;
	[self addSubview:scrollviewPage];

	[viewfirst showInView:scrollviewPage];	//画面サイズから場合分け

	
     pager.userInteractionEnabled = NO;
     
	[self addSubview:pager];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	pager.currentPage = scrollviewPage.contentOffset.x / self.frame.size.width;
}


@end
