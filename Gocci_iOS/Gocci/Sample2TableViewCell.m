//
//  Sample2TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample2TableViewCell.h"

@implementation Sample2TableViewCell
@synthesize UsersName;
@synthesize UsersPicture;
@synthesize RestaurantName;
@synthesize Goodnum;
@synthesize Review;
@synthesize movieView;
@synthesize thumbnailView;
@synthesize Commentnum;
@synthesize starImage;

- (void)dealloc
{
    self.RestaurantName = nil;
    self.UsersPicture = nil;
    self.UsersName = nil;
    self.Goodnum = nil;
    self.Review = nil;
    self.contentViewFront = nil;
    self.movieView = nil;
    self.thumbnailView = nil;
    self.Commentnum = nil;
    //self.deleteBtn = nil;
    self.starImage = nil;
};


- (void)viewDidLoad
{
    

}

- (void)awakeFromNib
{
    // Initialization code
    //JSONをパース
    NSString *timelineString = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/timeline/"];
    NSURL *url = [NSURL URLWithString:timelineString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    dispatch_async(q_global, ^{
        // 動画URL
        NSArray *movie = [jsonDic valueForKey:@"movie"];
        _movie_ = [movie mutableCopy];
        
        dispatch_async(q_main, ^{
        });
    });

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)playMovie
{
    NSLog(@"この時点ではうまくいってるよ");
    thumbnailView.hidden = NO;

    //動画再生
    //NSString *text = [_movie_ objectAtIndex:indexPath.row];
   NSString * text = @"http://api-gocci.jp/api/public/movies/9CEB01A25F1057266569723912192_18af28e14db.4.8.17821257160131575357.mp4";
    NSURL *url = [NSURL URLWithString:text];
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //[moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    CGRect frame = CGRectMake(0, 64, 320, 320);
    
    [moviePlayer.view setFrame:frame];
    //[moviePlayer.view setFrame:_cell.movieView.frame];
     [self.contentView addSubview: moviePlayer.view];
    
    //動画サムネイル画像の表示
    
    NSURL *myURL = [NSURL URLWithString: @"http://api-gocci.jp/api/public/thumbnail/9CEB01A25F1057266569723912192_18af28e14db.4.8.17821257160131575357.jpg"];
    NSData * myData = [NSData dataWithContentsOfURL:myURL];
    UIImage *myImage = [UIImage imageWithData:myData];
    thumbnailView.image = myImage;
    [self.contentView addSubview:thumbnailView];
   // [self.contentView bringSubviewToFront:thumbnailView];
  /*
    NSString *dottext2 = @"http://api-gocci.jp/api/public/thumbnail/9CEB01A25F1057266569723912192_18af28e14db.4.8.17821257160131575357.jpg";
    NSURL *myURL = [NSURL URLWithString:dottext2];
    NSData *data = [NSData dataWithContentsOfURL:myURL];
    UIImage *image = [UIImage imageWithData:data];
    _dotimageView.image = image;
    CGRect rect = CGRectMake(0, 64, 320, 320);
    _dotimageView.frame = rect;
    [self.contentView addSubview:_dotimageView];
    // [self.contentView bringSubviewToFront:thumbnailView];
    [self.contentView bringSubviewToFront:_dotimageView];
    */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer prepareToPlay];
    [moviePlayer play];
    
}

-(void)movieLoadStateDidChange:(id)sender{
    if(MPMovieLoadStatePlaythroughOK ) {
        NSLog(@"STATE CHANGED");
       thumbnailView.hidden = YES;
    }
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    //繰り返し
    [moviePlayer play];
}



@end
