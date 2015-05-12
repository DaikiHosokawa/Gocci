//
//  SCSecondView.h
//  Gocci
//
//  Created by デザミ on 2015/05/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "SCTenmeiView.h"

@protocol SCSecondViewDelegate <NSObject>
//@optional
-(void)goBeforeRecorder;
-(void)goKakakuText;


@end

@interface SCSecondView : UIView<UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate>
@property(nonatomic,strong) id<SCSecondViewDelegate> delegate;

- (void)showInView:(UIView *)view offset:(CGPoint)offset back:(NSInteger)index;


-(void)setTenmeiString:(NSString*)name;
-(void)setKakakuValue:(int)value;
-(void)setCategoryIndex:(int)index;
-(void)setFunikiIndex:(int)index;
-(void)reloadTableList;

#pragma mark 生成
+ (instancetype)create;

@end
