//
//  TutorialSubPageViewController.m
//  Gocci
//
//  Created by Ma Wa on 18.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "TutorialSubPageViewController.h"
#import "NetOp.h"


@interface TutorialSubPageViewController (){
    //NSArray *pages;
}





@end

@implementation TutorialSubPageViewController

-(void)registerUsername:(NSString*)username {
    

    
}


- (IBAction)timeLinebuttonClicked:(id)sender {
    
    NSLog(@"Clicked");
    
    
    // registerd user, already using gocci
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"identity_id"]){
        [NetOp loginWithIID:[[NSUserDefaults standardUserDefaults] valueForKey:@"identity_id"] andThen:^(NetOpResult ecode, NSString *emsg)
         {
             if (ecode == NETOP_SUCCESS) {
                 UIStoryboard* secondStoryboard = [UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil];
                 UIViewController* secondViewController = [secondStoryboard instantiateViewControllerWithIdentifier:@"achtung"];
                 
                 [self presentViewController: secondViewController animated:YES completion: NULL];
                 
             }
             else
                 NSLog(@"CANT LOGIN :(");
         
         }];
        
    }
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //self.p1FirstShortLabel.adjustsFontSizeToFitWidth = YES;
    //self.p1FirstShortLabel.minimumScaleFactor = .5f;
    //self.p1FirstShortLabel.font.
    
    
//    self.secondLongLabel.adjustsFontSizeToFitWidth = YES;
//    self.secondLongLabel.minimumScaleFactor = .5f;
}


@end