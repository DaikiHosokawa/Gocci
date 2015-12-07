//
//  CollectionViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MypageViewController.h"

@class  CollectionViewController;

@protocol  CollectionViewControllerDelegate1 <NSObject>
//@optional
-(void)collection:(CollectionViewController *)vc
           postid:(NSString*)postid;

-(void)collection:(CollectionViewController *)vc
          rest_id:(NSString*)rest_id;

@end

@interface CollectionViewController : UICollectionViewController

@property id supervc;

@property(nonatomic,strong) id<CollectionViewControllerDelegate1> delegate;

@property (nonatomic, strong) NSMutableArray *receiveDic2;
@property (nonatomic) CGRect soda;

@end
