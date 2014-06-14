//
//  CameraViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/11.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mergeCompleteEventReceived = NO;
    self.playVideoBtn.enabled = NO;
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
    [self.navigationController setNavigationBarHidden:YES animated:NO]; // ナビゲーションバー非表示

}

#pragma mark - Interaction Handlers (Alphabetical Order)

- (IBAction)onCreateVideo:(id)sender
{
    videoMaker = [[AppendableVideoMaker alloc] init];
    
    if ([videoMaker deviceCanRecordVideos])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoMergeCompleteHandler:)
                                                     name:@"AppendableVideoMaker_VideoMergeComplete" object:nil];
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            [self presentViewController:videoMaker animated:YES completion:^{}];
        }
        else
        {
            // Deprecated in iOS 6
            
            [self presentViewController:videoMaker animated:YES completion: nil];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"This device is not able to record videos! :("
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)onPlayVideo:(id)sender
{
    if ([videoMaker videoIsReady])
    {
        player = [[MPMoviePlayerController alloc] initWithContentURL:[videoMaker getVideoURL]];
        player.view.frame = self.videoView.bounds;
        player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.videoView addSubview:player.view];
        [player play];
    }
    else if (![videoMaker videoIsReady])
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Video has not finished merging! Please be patient.."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"You need to record a video first!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - Event Handlers

- (void)videoMergeCompleteHandler:(NSNotification*)notification
{
    [self.playVideoBtn setEnabled:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"Success"
                                message:@"Your merged video is now ready to watch!"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
