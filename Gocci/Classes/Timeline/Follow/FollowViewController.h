//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SortableTimeLineSubViewProtocol.h"


@class FollowViewController;

@protocol FollowViewControllerDelegate <NSObject>
//@optional
-(void)follow:(FollowViewController*)vc
            postid:(NSString*)postid;

-(void)follow:(FollowViewController *)vc
          username:(NSString*)user_id;

-(void)follow:(FollowViewController *)vc
           rest_id:(NSString*)rest_id;

@end

@interface FollowViewController : UICollectionViewController <SortableTimeLineSubView>

@property id supervc; //親
@property(nonatomic,strong) id<FollowViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

- (void)sortFunc:(NSString *)category;
- (void)sortValue:(NSString *)value;

@end


