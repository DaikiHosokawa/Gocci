//
//  MapViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/05.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>


@interface MapViewController : UIViewController<GMSMapViewDelegate>

@property id supervc;

@property (nonatomic, strong) NSDictionary *receiveDic3;

@end
