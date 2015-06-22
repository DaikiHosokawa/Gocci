//
//  RecorderSubmitPopupView.m
//  Gocci
//

#import "RecorderSubmitPopupView.h"
#import "BFPaperCheckbox.h"
#import "AppDelegate.h"

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
    
    //view.checkboxes = @[view.checkbox1];
    
    NSString *str1 = @"0";
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.cheertag = str1;
    NSLog(@"cheertag:%@",str1);
    /*
    for (NSUInteger i=0; i<[view.checkboxes count]; i++) {
        BFPaperCheckbox *checkbox = view.checkboxes[i];
        checkbox.delegate = view;
        checkbox.tag = (i+1);
        checkbox.layer.cornerRadius = 0.0;
    }
     */
    
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
    //[self _validateCheckboxes];
    //ここに必要情報入力してくださいを入力する
    
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


- (IBAction)tapKakuCan:(UIButton *)sender {

    [self dismiss];

}


#pragma mark - BGPaperCheckboxDelegate

- (void)paperCheckboxChangedState:(BFPaperCheckbox *)changedCheckbox
{
    if (!changedCheckbox.isChecked) {
        NSString *str1 = @"0";
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        delegate.cheertag = str1;
        NSLog(@"cheertag:%@",str1);
        return;
    }
    
    for (BFPaperCheckbox *checkbox in self.checkboxes) {
        if (changedCheckbox != checkbox) {
            [checkbox uncheckAnimated:YES];
            continue;
        }
        
        // TODO: チェックボックス選択時の処理
        LOG(@"%@番目のチェックボックスを選択", @(changedCheckbox.tag));
        // NSIntegerを文字列に変換
        NSString *str2 = [NSString stringWithFormat:@"%ld", (long)changedCheckbox.tag];
        // グローバル変数に保存
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        delegate.cheertag = str2;
        NSLog(@"cheertag:%@",str2);
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
            NSLog(@"チェックされています");
            return YES;
        }
    }
    
    return NO;
}


@end
