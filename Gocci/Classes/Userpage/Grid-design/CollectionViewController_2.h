//
//  CollectionViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserpageViewController.h"

@class  CollectionViewController_2;

@protocol  CollectionViewController_2Delegate <NSObject>
//@optional
-(void)collection_2:(CollectionViewController_2 *)vc
             postid:(NSString*)postid;

-(void)collection_2:(CollectionViewController_2 *)vc
            rest_id:(NSString*)rest_id;

@end

@interface CollectionViewController_2 : UICollectionViewController

@property id supervc;

@property(nonatomic,strong) id<CollectionViewController_2Delegate> delegate;

@property (nonatomic, strong) NSMutableArray *receiveDic2;
@property (nonatomic) CGRect soda;

@end
