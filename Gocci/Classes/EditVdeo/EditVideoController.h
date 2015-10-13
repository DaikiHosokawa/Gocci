//
//  EditVideoController.h
//  Gocci
//
//  Created by Castela on 2015/10/12.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface EditVideoController : UIViewController<SCPlayerDelegate, SCAssetExportSessionDelegate>

@property (strong, nonatomic) SCRecordSession *recordSession;
@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;
//@property (weak, nonatomic) IBOutlet UILabel *filterNameLabel;
//@property (weak, nonatomic) IBOutlet UIView *exportView;
//@property (weak, nonatomic) IBOutlet UIView *progressView;

@end
