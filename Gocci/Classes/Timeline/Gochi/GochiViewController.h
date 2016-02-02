//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SortableTimeLineSubViewProtocol.h"


@class GochiViewController;

@protocol GochiViewControllerDelegate <NSObject>

-(void)gochi:(GochiViewController*)vc
            postid:(NSString*)postid;

-(void)gochi:(GochiViewController *)vc
          username:(NSString*)user_id;

-(void)gochi:(GochiViewController *)vc
           rest_id:(NSString*)rest_id;

@end

@interface GochiViewController : UICollectionViewController <SortableTimeLineSubView>

@property id supervc;

@property(nonatomic,strong) id<GochiViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

- (void)sortFunc:(NSString *)category;
- (void)sortValue:(NSString *)value;

@end


