//
//  TableViewCell.m
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

@synthesize thumb = _thumb;

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)dealloc
{
    self.thumb = nil;
    self.restname = nil;
    self.postDate = nil;
};

@end
