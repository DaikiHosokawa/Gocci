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
    self.graphicBaseView.center = CGPointMake(self.frame.size.width / 2.0, self.graphicBaseView.center.y);
    [self.graphicBaseView addSubview:self.graphicView];
    self.graphicView.center = CGPointMake(self.graphicBaseView.frame.size.width / 2.0,
                                          self.graphicBaseView.frame.size.height / 2.0);
    
    self.titleLabel.center = CGPointMake(self.frame.size.width / 2.0, self.titleLabel.center.y);
    self.descriptionLabel.center = CGPointMake(self.frame.size.width / 2.0, self.descriptionLabel.center.y);
    
    LOG(@"self.frame=%@", NSStringFromCGRect(self.frame));
}

@end
