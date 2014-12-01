//
//  Sample5TableViewCell.h
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Sample5TableViewCell_other : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Goodnum;
@property (weak, nonatomic) IBOutlet UIView *contentViewFront;
@property (weak, nonatomic) Sample5TableViewCell_other *cell;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *Commentnum;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UIImageView *starImage;
@property (weak, nonatomic) IBOutlet UIButton *RestnameButton;

@end
