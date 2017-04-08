//
//  SGActionMenu.h
//  SGActionView
//
//  Created by Sagi on 13-9-3.
//  Copyright (c) 2013年 AzureLab. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SGActionViewStyle){
    SGActionViewStyleLight = 0,
    SGActionViewStyleDark
    
};

typedef void(^SGMenuActionHandler)(NSInteger index);

@interface SGActionView : UIView

@property (nonatomic, assign) SGActionViewStyle style;

+ (SGActionView *)sharedActionView;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               buttonTitle:(NSString *)buttonTitle
            selectedHandle:(SGMenuActionHandler)handler;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
           leftButtonTitle:(NSString *)leftTitle
          rightButtonTitle:(NSString *)rightTitle
            selectedHandle:(SGMenuActionHandler)handler;


+ (void)showSheetWithTitle:(NSString *)title
                itemTitles:(NSArray *)itemTitles
             selectedIndex:(NSInteger)selectedIndex
            selectedHandle:(SGMenuActionHandler)handler;



+ (void)showSheetWithTitle:(NSString *)title
                itemTitles:(NSArray *)itemTitles
             itemSubTitles:(NSArray *)itemSubTitles
             selectedIndex:(NSInteger)selectedIndex
            selectedHandle:(SGMenuActionHandler)handler;


+ (void)showGridMenuWithTitle:(NSString *)title
                   itemTitles:(NSArray *)itemTitles
                       images:(NSArray *)images
               selectedHandle:(SGMenuActionHandler)handler;


@end
