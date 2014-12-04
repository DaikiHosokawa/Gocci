#import "MoviePlayerManager.h"
#import "APIClient.h"

@interface MoviePlayerManager()
@property (nonatomic,strong) NSMutableArray *players;
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
    
    self.players = [NSMutableArray arrayWithCapacity:0];
    
    return self;
}


#pragma mark - Public Methods

- (void)addPlayerWithMovieURL:(NSString *)urlString size:(CGSize)size atIndex:(NSUInteger)index completion:(void (^)(BOOL))completion
{
    if ([self.players count] > index) {
        return;
    }
    
    // 仮で空の MPMoviePlayerController オブジェクトを格納
    [self.players addObject:[MPMoviePlayerController new]];
    
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
                          
                          [weakSelf.players replaceObjectAtIndex:index withObject:moviePlayer];
                          
                          completion(YES);
                      }];
}

- (void)removeAllPlayers
{
    for (MPMoviePlayerController *p in self.players) {
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
    if ([self.players count] <= index) {
        return nil;
    }
    
    MPMoviePlayerController *player = self.players[index];
    
    if (!player.contentURL) {
        return nil;
    }
    
    // 指定されたもの以外の再生を停止状態にする
    for (MPMoviePlayerController *p in self.players) {
        if (p == player) {
            continue;
        }
        [p stop];
    }
    
    return player;
}


@end
