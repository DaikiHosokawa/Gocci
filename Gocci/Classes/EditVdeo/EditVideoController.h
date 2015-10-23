//
//  EditVideoController.h
//  Gocci
//
//  Created by Castela on 2015/10/12.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@protocol EditVideoDelegate <NSObject>
-(void)retake;
@end

@interface EditVideoController : UIViewController<SCPlayerDelegate, SCAssetExportSessionDelegate, UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) id<EditVideoDelegate> delegate;
@property (strong, nonatomic) SCRecordSession *recordSession;
@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end
