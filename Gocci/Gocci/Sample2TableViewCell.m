//
//  Sample2TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample2TableViewCell.h"

@implementation Sample2TableViewCell
@synthesize UsersName;
@synthesize UsersPicture;
@synthesize RestaurantName;
@synthesize Goodnum;
@synthesize Review;
@synthesize movieView;
@synthesize thumbnailView;

- (void)dealloc
{
    self.RestaurantName = nil;
    self.UsersPicture = nil;
    self.UsersName = nil;
    self.Goodnum = nil;
    self.Review = nil;
    self.contentViewFront = nil;
    self.movieView = nil;
    self.thumbnailView = nil;
};



- (void)viewDidLoad
{
    

}
/*
-(IBAction)disp:(id)sender{
    int count;
    count = Goodnum;
    count++;
    NSString *add = [NSString stringWithFormat : @"%d",count];
    _cell.Goodnum.text = add;
}
*/

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
