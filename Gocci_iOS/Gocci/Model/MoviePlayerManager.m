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
    
    if (self.players[key]) {
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [APIClient downloadMovieFile:urlString
                      completion:^(NSURL *fileURL, NSError *error) {
                          if (fileURL == nil || error != nil) {
                              completion(NO);
                              return;
                          }
                          
                          MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
                          moviePlayer.controlStyle = MPMovieControlStyleNone;
                          moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
                          moviePlayer.repeatMode = MPMovieRepeatModeOne;
                          moviePlayer.view.frame = CGRectMake(0, 0, size.width, size.height);
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
        [self.globalPlayer play];
    }
}

- (void)playMovieAtIndex:(NSUInteger)index inView:(UIView *)view frame:(CGRect)frame
{
    if (self.globalPlayer) {
        [self.globalPlayer.view removeFromSuperview];
    }
    
    self.globalPlayer = [self _playerAtIndex:index];
    
    if (self.globalPlayer) {
        self.globalPlayer.view.frame = frame;
        [view addSubview:self.globalPlayer.view];
        [self.globalPlayer play];
    }
}

- (void)stopMovie
{
    if (self.globalPlayer) {
        [self.globalPlayer stop];
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
