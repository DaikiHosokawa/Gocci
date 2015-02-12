//
//  TutorialPageView.m
//  Gocci
//

#import "TutorialPageView.h"

@interface TutorialPageView()

@property (nonatomic, weak) IBOutlet UIView *graphicView;
@property (nonatomic, weak) IBOutlet UIView *graphicBaseView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end

@implementation TutorialPageView

+ (instancetype)viewWithNibName:(NSString *)nibName
{
    return [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
}

- (void)setup
{
    // イラストを画面上部に中央寄せで配置
    self.graphicBaseView.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.width / 2.0);
    [self.graphicBaseView addSubview:self.graphicView];
    self.graphicView.center = CGPointMake(self.graphicBaseView.frame.size.width / 2.0,
                                          self.graphicBaseView.frame.size.height / 2.0);
    
    // タイトル・説明を中央・下寄せに配置
    self.descriptionLabel.center = CGPointMake(self.frame.size.width / 2.0,
                                               self.frame.size.height - self.descriptionLabel.frame.size.height);
    self.titleLabel.center = CGPointMake(self.frame.size.width / 2.0,
                                         self.frame.size.height - self.descriptionLabel.frame.size.height - self.titleLabel.frame.size.height - 8.0);
}

@end
