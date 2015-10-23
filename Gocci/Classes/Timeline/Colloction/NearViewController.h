//
//  CollectionViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NearViewController;

@protocol NearViewControllerDelegate <NSObject>
//@optional
-(void)near:(NearViewController*)vc
            postid:(NSString*)postid;

-(void)near:(NearViewController *)vc
          username:(NSString*)user_id;

-(void)near:(NearViewController *)vc
           rest_id:(NSString*)rest_id;

@end

@interface NearViewController : UICollectionViewController

@property id supervc; //親
@property(nonatomic,strong) id<NearViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

- (void)sortFunc:(NSString *)category;
- (void)sortValue:(NSString *)value;

@end


