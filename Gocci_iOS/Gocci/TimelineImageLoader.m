//
//  TimelineImageLoader.m
//  Gocci
//
//  Created by INASE on 2014/10/05.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "TimelineImageLoader.h"

@implementation TimelineImageLoader

+ (UIImage*)imageWithURL:(NSURL*)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}



@end
