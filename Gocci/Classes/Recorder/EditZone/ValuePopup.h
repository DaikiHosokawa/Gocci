//
//  PopupViewController2.h
//  Gocci
//
//  Created by Castela on 2015/10/06.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ValuePopup;

@protocol ValuePopupDelegate <NSObject>

- (void)valuePopup:(ValuePopup *)vc didFinishWithSelections:(NSArray *)selections;


@end

@interface ValuePopup : UIViewController

@property (nonatomic, weak) id<ValuePopupDelegate> delegate;
@property (nonatomic, strong) NSArray *defaultSelections;

@end
