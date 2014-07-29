//
//  Sample2TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample2TableViewCell.h"

@interface Sample2TableViewCell()

@end

@implementation Sample2TableViewCell

- (void)viewDidLoad
{
    
    NSURL *url = [NSURL URLWithString:@"http://codecamp1353.lesson2.codecamp.jp/dst/hoge.mp4"];
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //スペースをつくる
    CGRect frame = CGRectMake(40, 0, 240, 240);
    //moviePlayerのビューを　frameに設定する
    [moviePlayer.view setFrame:frame];
    [self.viewForBaselineLayout addSubview: moviePlayer.view];
    [self.viewForBaselineLayout bringSubviewToFront:moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [moviePlayer play];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
