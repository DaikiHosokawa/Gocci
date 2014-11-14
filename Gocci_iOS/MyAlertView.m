//
//  MyAlertView.m
//  Gocci
//
//  Created by Jack O' Lantern on 2014/11/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "MyAlertView.h"

@implementation MyAlertView

@synthesize clickedButtonAtIndex = clickedButtonAtIndex_;
@synthesize cancel = cancel_;

+(void) alertWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle
          clickedBlock:(void (^)(UIAlertView* alertView, NSInteger buttonIndex))clickedButtonAtIndex cancelBlock:(void (^)(UIAlertView* alertView))cancel
     otherButtonTitles:(NSString*)titles,...;
{
    
    MyAlertView* myAlertView = [[MyAlertView alloc] initWithClickedBlock:clickedButtonAtIndex cancelBlock:cancel];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:myAlertView cancelButtonTitle:cancelButtonTitle otherButtonTitles:titles, nil];
    [alertView show];
    alertView.delegate = nil;
}

- (void) dealloc;
{
    
    
}

-(id)initWithClickedBlock:(void (^)(UIAlertView* alertView, NSInteger buttonIndex))clickedButtonAtIndex cancelBlock:(void (^)(UIAlertView* alertView))cancel;{
    self = [super init];
    if (self) {
        self.clickedButtonAtIndex = clickedButtonAtIndex;
        self.cancel = cancel;
    }
    
    return self;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;{
    clickedButtonAtIndex_(alertView, buttonIndex);
}

-(void)alertViewCancel:(UIAlertView *)alertView;
{
    cancel_(alertView);
}
@end