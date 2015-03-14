//
//  RecorderSubmitPopupView.m
//  Gocci
//

#import "RecorderSubmitPopupView.h"
#import "BFPaperCheckbox.h"

@interface RecorderSubmitPopupView()
<BFPaperCheckboxDelegate>

@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox1;
@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox2;
@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox3;
@property (nonatomic, weak) IBOutlet BFPaperCheckbox *checkbox4;

@property (nonatomic, copy) NSArray *checkboxes;

@end

@implementation RecorderSubmitPopupView

+ (instancetype)view
{
    RecorderSubmitPopupView *view = [[NSBundle mainBundle] loadNibNamed:@"RecorderSubmitPopupView" owner:self options:nil][0];
    
    view.checkboxes = @[view.checkbox1, view.checkbox2, view.checkbox3, view.checkbox4];
    
    for (NSUInteger i=0; i<[view.checkboxes count]; i++) {
        BFPaperCheckbox *checkbox = view.checkboxes[i];
        checkbox.delegate = view;
        checkbox.tag = (i+1);
        checkbox.layer.cornerRadius = 0.0;
    }
    
    return view;
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
    if (![self _validateCheckboxes]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"どれか1つを選択してください"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
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


#pragma mark - BGPaperCheckboxDelegate

- (void)paperCheckboxChangedState:(BFPaperCheckbox *)changedCheckbox
{
    if (!changedCheckbox.isChecked) {
        return;
    }
    
    for (BFPaperCheckbox *checkbox in self.checkboxes) {
        if (changedCheckbox != checkbox) {
            [checkbox uncheckAnimated:YES];
            continue;
        }
        
        // TODO: チェックボックス選択時の処理
        LOG(@"%@番目のチェックボックスを選択", @(changedCheckbox.tag));
    }
}


#pragma mark - Private Methods

/**
 *  チェックボックスのどれか1つが選択されているか
 *
 *  @return
 */
- (BOOL)_validateCheckboxes
{
    for (BFPaperCheckbox *checkbox in self.checkboxes) {
        if (checkbox.isChecked) {
            return YES;
        }
    }
    
    return NO;
}


@end
