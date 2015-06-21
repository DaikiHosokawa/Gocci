#import "MoviePlayerManager.h"
#import "APIClient.h"

@interface MoviePlayerManager()

/** MPMoviePlayerController を格納 */
@property (nonatomic,strong) NSMutableDictionary *players;

/** 再生用の MPMoviePlayerController */
@property (nonatomic,strong) MPMoviePlayerController *globalPlayer;


@end

@implementation MoviePlayerManager

static MoviePlayerManager *_sharedInstance = nil;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [MoviePlayerManager new];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    self.players = [NSMutableDictionary dictionaryWithCapacity:0];
    
    return self;
}


#pragma mark - Public Methods

- (void)addPlayerWithMovieURL:(NSString *)urlString size:(CGSize)size atIndex:(NSUInteger)index completion:(void (^)(BOOL))completion
{
    NSString *key = [NSString stringWithFormat:@"%@", @(index)];
    LOG(@"players[%@]=%@", key, self.players[key]);
    /*
    if (self.players[key]) {
        return;
    }
     */
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak typeof(self)weakSelf = self;
    [APIClient downloadMovieFile:urlString
                      completion:^(NSURL *fileURL, NSError *error) {
                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                          
                          if (fileURL == nil || error != nil) {
                              [self.players removeObjectForKey:key];
                              completion(NO);
                              return;
                          }
                          MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] init];
                          moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
                          [moviePlayer setContentURL:fileURL];
                          moviePlayer.controlStyle = MPMovieControlStyleNone;
                          moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
                          moviePlayer.repeatMode = MPMovieRepeatModeOne;
                          moviePlayer.view.frame = CGRectMake(0, 0, size.width, size.height);
                          moviePlayer.view.userInteractionEnabled = NO;
                          weakSelf.players[key] = moviePlayer;
                          
                          
                          completion(YES);
                      }];
}


- (void)removeAllPlayers
{
    for (MPMoviePlayerController *p in [self.players allValues]) {
        [p stop];
    }
    
    [self.players removeAllObjects];
    self.globalPlayer = nil;
}

- (void)scrolling:(BOOL)scrolling
{
    if (!self.globalPlayer) {
        return;
    }
    
    if (scrolling) {
        self.globalPlayer.view.alpha = 0.0;
        [self.globalPlayer pause];
    } else {
        self.globalPlayer.view.alpha = 1.0;
        
        if ([self.globalPlayer playbackState] != MPMoviePlaybackStatePlaying) {
            [self.globalPlayer play];
        }
    }
}

- (void)playMovieAtIndex:(NSUInteger)index inView:(UIView *)view frame:(CGRect)frame
{
    if (self.globalPlayer) {
 
        [self.globalPlayer.view removeFromSuperview];
       // [self.globalPlayer pause];
        self.globalPlayer = nil;
      
        /*
        //再生中でない時
        if ([self.globalPlayer playbackState] == MPMoviePlaybackStatePlaying) {
            NSLog(@"再生中に停止します");
            MPMoviePlayerController *player = [self _playerAtIndex:index];
            self.globalPlayer = player;
            [self.globalPlayer pause];
        }
       else if ([self.globalPlayer playbackState] == MPMoviePlaybackStatePaused) {
            NSLog(@"停止中に再生します");
            //MPMoviePlayerController *player = [self _playerAtIndex:index];
            //self.globalPlayer = player;
            [self.globalPlayer play];
        }
         */

    }
    
    
    MPMoviePlayerController *player = [self _playerAtIndex:index];
    
    if (player && player != self.globalPlayer) {
        self.globalPlayer = player;
        self.globalPlayer.view.frame = frame;
        [view addSubview:self.globalPlayer.view];
        
        //再生中でない時
        if ([self.globalPlayer playbackState] != MPMoviePlaybackStatePlaying) {
            [self.globalPlayer play];
        }
    
        /*
        //再生中のとき
        else if ([self.globalPlayer playbackState] == MPMoviePlaybackStatePlaying) {
            [self.globalPlayer play];
            NSLog(@"再生中");
        }else if ([self.globalPlayer playbackState] == MPMoviePlaybackStateSeekingForward) {
             NSLog(@"待機中");
        }
         */
    }
}

- (void)stopMovie
{
    if (self.globalPlayer) {
        [self.globalPlayer stop];
        self.globalPlayer = nil;
    }
}


#pragma mark - Private Method

- (MPMoviePlayerController *)_playerAtIndex:(NSUInteger)index
{
    
    
    NSString *key = [NSString stringWithFormat:@"%@", @(index)];
    if (!self.players[key]) {
        return nil;
    }
    
    MPMoviePlayerController *player = self.players[key];
    
    if (!player.contentURL) {
        return nil;
    }
    
    // 指定されたもの以外の再生を停止状態にする
    for (MPMoviePlayerController *p in [self.players allValues]) {
        if (p == player) {
            continue;
        }
        [p stop];
    }
    
    return player;
}


@end
