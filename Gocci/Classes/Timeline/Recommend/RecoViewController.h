//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SortableTimeLineSubViewProtocol.h"


@class RecoViewController;

@protocol RecoViewControllerDelegate <NSObject>

-(void)reco:(RecoViewController*)vc
            postid:(NSString*)postid;

-(void)reco:(RecoViewController *)vc
          username:(NSString*)user_id;

-(void)reco:(RecoViewController *)vc
           rest_id:(NSString*)rest_id;

@end

@interface RecoViewController : UICollectionViewController <SortableTimeLineSubView>

@property id supervc;

@property(nonatomic,strong) id<RecoViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;


- (void)sort:(NSString *)value category:(NSString *)category;

@end


