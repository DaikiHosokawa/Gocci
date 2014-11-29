#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

/**
 *  動画プレイヤー管理
 */
@interface MoviePlayerManager : NSObject

+ (instancetype)sharedManager;

/**
 *  Movie Player を追加
 *
 *  @param urlString  動画の URL
 *  @param size       プレイヤーに指定する CGSize
 *  @param index
 *  @param completion 完了後に実行する処理
 */
- (void)addPlayerWithMovieURL:(NSString *)urlString size:(CGSize)size atIndex:(NSUInteger)index completion:(void (^)(BOOL success))completion;

/**
 *  全ての Movie Player を消去
 */
- (void)removeAllPlayers;

/**
 *  スクロール中に動画再生を停止する
 *
 *  @param scrolling
 */
- (void)scrolling:(BOOL)scrolling;

/**
 *  index にある動画を再生する
 *
 *  @param index
 *  @param view  動画プレイヤーを addSubView する親 View
 *  @param frame 動画プレイヤーに指定する frame
 */
- (void)playMovieAtIndex:(NSUInteger)index inView:(UIView *)view frame:(CGRect)frame;

/**
 *  再生中の動画を停止する
 */
- (void)stopMovie;

@end
