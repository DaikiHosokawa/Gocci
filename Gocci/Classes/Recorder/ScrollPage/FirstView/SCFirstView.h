//
//  SCFirstView.h
//  Gocci
//
//  Created by INASE on 2015/05/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XYPieChart.h"

@protocol SCFirstViewDelegate <NSObject>
-(void)recordBegan;
-(void)recordEnded;
-(void)flipCamera;
-(void)handleReverseCameraTapped;
-(void)retake;
@end

@interface SCFirstView : UIView<XYPieChartDelegate,XYPieChartDataSource>
@property(nonatomic,strong) id<SCFirstViewDelegate> delegate;

#pragma mark - addsubview
- (void)showInView:(UIView *)view;

#pragma mark - 円グラフ
-(void)updatePieChartWith:(double)now MAX:(double)max;

#pragma mark
+ (instancetype)create;

@end
