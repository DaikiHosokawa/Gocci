//
//  SettingViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/05.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPopup.h"

@interface SettingViewController : UITableViewController<UIAlertViewDelegate>
{
    NSArray *sectionList;
    NSDictionary *dataSource;
    UIAlertView *ADValertView;
    UIAlertView *PASalertView;
}

@end
