//
//  SampleTableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/02.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SampleTableViewCell : UITableViewCell{
    NSMutableArray *venues_;
}
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *restaurantAddress;
@property (weak, nonatomic) IBOutlet UILabel *meter;
@property (weak, nonatomic) SampleTableViewCell *cell;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *categoryname;

@end