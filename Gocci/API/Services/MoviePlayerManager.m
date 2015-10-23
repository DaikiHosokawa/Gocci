#import "MoviePlayerManager.h"
#import "APIClient.h"

@interface MoviePlayerManager()

/** MPMoviePlayerController を格納 */
@property (nonatomic,strong) NSMutableDictionary *players;

/* 再生用の MPMoviePlayerController */
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
    //__weak typeof(self)weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"fileURL:%@",url);
    
    
    MPMoviePlayerController *moviePlayer =  [[MPMoviePlayerController alloc] init];
    moviePlayer.view.layer.cornerRadius = 5;
    moviePlayer.view.clipsToBounds = true;
    moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    [moviePlayer setContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    moviePlayer.repeatMode = MPMovieRepeatModeOne;
    moviePlayer.view.frame = CGRectMake(0, 0, size.width, size.height);
    moviePlayer.view.userInteractionEnabled = NO;
    moviePlayer.backgroundView.opaque = NO;
    //movieplayerのbackgroundViewの透明化
    moviePlayer.backgroundView.backgroundColor = [UIColor clearColor];
    for(UIView *aSubView in moviePlayer.view.subviews) {
        aSubView.backgroundColor = [UIColor clearColor];
    }
    
    moviePlayer.view.backgroundColor = [UIColor clearColor];
    self.players[key] = moviePlayer;
}


- (void)removeAllPlayers
{
    for (MPMoviePlayerController *p in [self.players allValues]) {
        [p stop];
    }
    [self.globalPlayer stop];
    [self.players removeAllObjects];
    self.globalPlayer = nil;
}

- (void)scrolling:(BOOL)scrolling
{
    NSLog(@"scrolling:%@",scrolling? @"YES":@"NO");
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
    }
    
    MPMoviePlayerController *player = [self _playerAtIndex:index];
    
    if (player && player != self.globalPlayer) {
        self.globalPlayer = player;
        self.globalPlayer.view.frame = frame;
        [view addSubview:self.globalPlayer.view];
        
        //再生中でない時
        if ([self.globalPlayer playbackState] != MPMoviePlaybackStatePlaying) {
            NSLog(@"再生中でないので再生");
            [self.globalPlayer play];
            
        }else{
            NSLog(@"再生中");
            [self.globalPlayer pause];
        }
        
    }
}

- (void)stopMovie
{
        [self.globalPlayer stop];
        self.globalPlayer = nil;
}


#pragma mark - Private Method

- (MPMoviePlayerController *)_playerAtIndex:(NSUInteger)index
{

    NSString *key = [NSString stringWithFormat:@"%@", @(index)];
    NSLog(@"再生するkey:%@",key);
    NSLog(@"player群は%@",self.players);
    NSLog(@"playerは%@",self.players[key]);
    if (!self.players[key]) {
         NSLog(@"keyがない");
        return nil;
    }
    
    MPMoviePlayerController *player = self.players[key];
    
    if (!player.contentURL) {
         NSLog(@"playerにurlがない");
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
