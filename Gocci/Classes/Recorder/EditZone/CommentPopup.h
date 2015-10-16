//
//  PopupViewController2.h
//  Gocci
//
//  Created by Castela on 2015/10/06.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CommentPopup;

@protocol CommentPopupDelegate <NSObject>

- (void)commentPopup:(CommentPopup *)vc didFinishWithSelections:(NSArray *)selections;


@end

@interface CommentPopup : UIViewController

@property (nonatomic, weak) id<CommentPopupDelegate> delegate;
@property (nonatomic, strong) NSArray *defaultSelections;

@end
