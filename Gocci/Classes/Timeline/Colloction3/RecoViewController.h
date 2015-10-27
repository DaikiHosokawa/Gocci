//
//  CollectionViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecoViewController;

@protocol RecoViewControllerDelegate <NSObject>
//@optional
-(void)reco:(RecoViewController*)vc
            postid:(NSString*)postid;

-(void)reco:(RecoViewController *)vc
          username:(NSString*)user_id;

-(void)reco:(RecoViewController *)vc
           rest_id:(NSString*)rest_id;

@end

@interface RecoViewController : UICollectionViewController

@property id supervc; //親
@property(nonatomic,strong) id<RecoViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

- (void)sortFunc:(NSString *)category;
- (void)sortValue:(NSString *)value;

@end


