//
//  RecorderSubmitPopupView.m
//  Gocci
//

#import "RecorderSubmitPopupView.h"
#import "BFPaperCheckbox.h"

@interface RecorderSubmitPopupView()

@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox1;
@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox2;
@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox3;
@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox4;

@end

@implementation RecorderSubmitPopupView

+ (instancetype)view
{
    return [[NSBundle mainBundle] loadNibNamed:@"RecorderSubmitPopupView" owner:self options:nil][0];
}

- (void)showInView:(UIView *)view
{
    self.frame = view.bounds;
    [view addSubview:self];
}

- (void)dismiss
{
    [self removeFromSuperview];
}


#pragma mark - Action

/**
 *  「Twitterでつぶやく」ボタン押下
 *
 *  @param sender
 */
- (IBAction)onTwitterShareButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(recorderSubmitPopupViewOnTwitterShare:)]) {
        [self.delegate recorderSubmitPopupViewOnTwitterShare:self];
    }
}

/**
 *  「Facebookでつぶやく」ボタン押下
 *
 *  @param sender
 */
- (IBAction)onFacebookShareButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(recorderSubmitPopupViewOnFacebookShare:)]) {
        [self.delegate recorderSubmitPopupViewOnFacebookShare:self];
    }
}

/**
 *  「投稿する」ボタン押下
 *
 *  @param sender
 */
- (IBAction)onSubmitButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(recorderSubmitPopupViewOnSubmit:)]) {
        [self.delegate recorderSubmitPopupViewOnSubmit:self];
    }
}

/**
 *  「キャンセル」ボタン押下
 *
 *  @param sender
 */
- (IBAction)onCancelButton:(id)sender
{
    if (self.cancelCallback) {
        self.cancelCallback();
    }
}

@end
