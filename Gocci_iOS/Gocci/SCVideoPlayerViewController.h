//
//   SCVideoPlayerViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoPlayerView.h"
#import "SCRecorder.h"

@interface SCVideoPlayerViewController : UIViewController<SCPlayerDelegate>{
    BOOL _isFadeIn;
}

@property (strong, nonatomic) SCRecordSession *recordSession;
@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;

@property (weak, nonatomic) IBOutlet UIButton *sampleButton;
@property (weak, nonatomic) IBOutlet UIImageView *sampleImageView;

- (IBAction)buttonFadeInOut:(id)sender;

@end
