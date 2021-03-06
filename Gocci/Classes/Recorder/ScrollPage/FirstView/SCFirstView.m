//
//  SCFirstView.m
//  Gocci
//
//  Created by INASE on 2015/05/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "SCFirstView.h"
#import "SCRecorder.h"

#import "SCTouchDetector.h"
#import "Swift.h"

@interface SCFirstView()
{
	XYPieChart *pieChartTimer;
	CGFloat percentPieChart;
	
	__weak IBOutlet UIView *recordView;
    
}

@end

@implementation SCFirstView

#pragma mark - addsubview
- (void)showInView:(UIView *)view
{
    NSLog(@"called showinview");
	//撮影ボタン
	{
        
		CGFloat width_record = recordView.frame.size.width * 1; // 90;
		CGFloat height_record = width_record;
		//CGFloat x_record = self.frame.size.width /2 - width_record /2;
		//CGFloat y_record = self.frame.origin.y;
        
        [recordView addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
        
		{
			//円グラフゲージ
			CGRect rect_pie = CGRectMake(0, 0, width_record, height_record);
			pieChartTimer = [[XYPieChart alloc] initWithFrame:rect_pie Center:CGPointMake(rect_pie.size.width/2, rect_pie.size.height/2) Radius:rect_pie.size.width/2];
			[pieChartTimer setDelegate:self];
			[pieChartTimer setDataSource:self];
			[pieChartTimer setShowPercentage:NO];
			[pieChartTimer setAnimationSpeed:1.0/60.0];
			//[pieChartTimer setPieBackgroundColor:[UIColor blackColor]];
			[recordView addSubview:pieChartTimer];
			[self updatePieChartWith:0 MAX:100];
			pieChartTimer.center = CGPointMake(recordView.frame.size.width/2, recordView.frame.size.height/2);
            [pieChartTimer reloadData];
            
			//アイコン
			CGFloat width_icon = width_record * 0.80; // 75;
			CGFloat height_icon = width_icon;
			UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_icon, height_icon)];
			UIImage *image = [UIImage imageNamed:@"icon_record_cam"];
			imageview.image = image;
			imageview.center = CGPointMake(recordView.frame.size.width/2, recordView.frame.size.height/2);
			[recordView addSubview:imageview];
            
		}
       
	}
    
    
	
	[view addSubview:self];
}

#pragma mark 撮影イベント開始
// recordViewでタップの有無を判定し、押している時だけ撮影、話している時にストップで作っています。
- (void)handleTouchDetected:(SCTouchDetector*)touchDetector
{
	if (touchDetector.state == UIGestureRecognizerStateBegan) {
		//NSLog(@"%s Began",__func__);
		[self.delegate recordBegan];
	}
	else if (touchDetector.state == UIGestureRecognizerStateEnded) {
		//NSLog(@"%s Ended",__func__);
		[self.delegate recordEnded];
	}
}
- (IBAction)reverseCamera:(id)sender {

    [self.delegate handleReverseCameraTapped];
}


- (IBAction)DeleteDraft:(id)sender {
    if (percentPieChart == 0.0){
        [self.delegate DeleteDraft];
    }else {
        UIAlertView *checkDelete  =[[UIAlertView alloc] initWithTitle:@"終了してよろしいですか？" message:@"撮影中の動画が削除されてしまいます" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        checkDelete.tag=121;
        [checkDelete show];
    }
}

- (IBAction)openEdit:(id)sender {
     [self.delegate openEdit];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 121 && buttonIndex == 0)
    {
        //code for opening settings app in iOS 8
        [self.delegate DeleteDraft];
    }
}


#pragma mark - 円グラフ
-(void)updatePieChartWith:(double)now MAX:(double)max
{
	percentPieChart = now / max;
    NSLog(@"First View now:%f,max:%f",now,max);
	if (percentPieChart > 1.0) percentPieChart = 1.0;
	[pieChartTimer reloadData];
}

-(void)expand{

    [UIView animateWithDuration:0.1
                     animations:^{
                         pieChartTimer.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     }
     ];
    
}

-(void)shrink{
    [UIView animateWithDuration:0.1
                     animations:^{
                         pieChartTimer.transform = CGAffineTransformIdentity;
                         
                     }];
}

-(void)complete{
    /*
    [UIView animateWithDuration:0.1f
                     animations:^{
                         recordView.transform = CGAffineTransformMakeScale(0, 0);
                     } completion:^(BOOL finished) {
                         // 画像を表示する
                         UIImage *image = [UIImage imageNamed:@"test1.png"];
                         UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                         imageView.center = recordView.center;
                         [recordView addSubview:imageView];
                         // アニメーションが終わった後実行する処理
                     }];
     */
}

#pragma mark - XYPieChart
#pragma mark スライスの数
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
	return 2;
}
#pragma mark スライスの割合
- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
	switch (index) {
		case 0:
			return percentPieChart;
			break;
			
		default:
			break;
	}
	
	return (1.0 - percentPieChart);
}
#pragma mark スライスの色
- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
	UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
	
	switch (index)
	{
		case 0:
			return color_custom; // [UIColor redColor];
			break;
			
		default:
			break;
	}
	return [UIColor lightGrayColor];
}


#pragma mark 生成
+ (instancetype)create
{
    NSString *nibName = @"SCFirstViewMain";
    //画面サイズから使用xibを場合分け
    CGRect rect = [UIScreen mainScreen].bounds;
    if (rect.size.height == 480) {
        //3.5inch
        nibName = @"SCFirstView_3_5_inch";
    }
    else if (rect.size.height == 667) {
        //4.7inch
        nibName = @"SCFirstView_4_7_inch";
    }
    else if (rect.size.height == 736) {
        //5.5inch
        nibName = @"SCFirstView_5_5_inch";
    }
    
    SCFirstView *view = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
    
    
    return view;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
