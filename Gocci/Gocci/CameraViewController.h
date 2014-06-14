//
//  CameraViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/11.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "AppendableVideoMaker.h"
#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@interface CameraViewController : AppendableVideoMaker
{
    AppendableVideoMaker *videoMaker;
    MPMoviePlayerController *player;
    BOOL mergeCompleteEventReceived;
}

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createVideoBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playVideoBtn;
@property (weak, nonatomic) IBOutlet UIView *videoView;

- (IBAction)onCreateVideo:(id)sender;
- (IBAction)onPlayVideo:(id)sender;

- (void)videoMergeCompleteHandler:(NSNotification*)notification;

@end
