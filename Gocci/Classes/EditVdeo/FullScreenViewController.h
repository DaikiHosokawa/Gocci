//
//  FullScreenViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/23.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface FullScreenViewController : UIViewController<SCPlayerDelegate, SCAssetExportSessionDelegate>

@property (strong, nonatomic) SCRecordSession *recordSession;
@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;

@end
