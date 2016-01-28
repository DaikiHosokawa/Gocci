//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SortableTimeLineSubViewProtocol.h"
#import "LocationClient.h"


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

@interface NearViewController : UICollectionViewController <SortableTimeLineSubView>

@property id supervc; 
@property(nonatomic,strong) id<NearViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

- (void)sortFunc:(NSString *)category;
- (void)sortValue:(NSString *)value;

- (void)updateForPosition:(CLLocationCoordinate2D)position;

@end


