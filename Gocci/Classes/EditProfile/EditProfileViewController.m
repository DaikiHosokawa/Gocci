//
//  EditProfileViewController.m
//  Gocci
//
//  INASE by Castela on 2015/10/06.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UIImageView+WebCache.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "APIClient.h"
#import "STPopup.h"
#import "CompletePopup.h"
#import "Swift.h"

@interface EditProfileViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate  >
{
    
    __weak IBOutlet UITextField *username;
    __weak IBOutlet UIImageView *userpicture;
    __weak IBOutlet UIButton *save;
    __weak IBOutlet UIView *background;
    UIImagePickerController *ipc;
    NSString *assetsUrl;
}


@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    username.text = Persistent.user_name;
    username.delegate = self;
    
    NSURL *url = [NSURL URLWithString:Persistent.user_profile_image_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    userpicture.image = image;
    userpicture.userInteractionEnabled = YES;
    userpicture.tag = 101;
    
    save.layer.cornerRadius = 3;
    save.clipsToBounds = YES;
    
    background.layer.borderColor = [UIColor grayColor].CGColor;
    
    background.layer.borderWidth = 1;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//tap picture
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ( touch.view.tag == userpicture.tag )
        [self clickLogo:userpicture];
}



-(IBAction)clickLogo:(id)sender
{
    NSLog(@"in clickLogo");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        ipc = [[UIImagePickerController alloc] init];
        [ipc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [ipc setAllowsEditing:YES];
        ipc.delegate = self;
        [self presentViewController:ipc animated:YES completion:nil];
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *ImgData = UIImagePNGRepresentation(editedImage);
        [ImgData writeToFile:imagePath atomically:YES];
        userpicture.image = editedImage;
    }
    
    NSString *head = @"file://";
    NSString *entire = [head stringByAppendingString:imagePath];
    assetsUrl = entire;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([textField.text length] > 0 ){
        NSLog(@"変更候補:%@",username.text);
        [textField resignFirstResponder];
    }else{
        username.text = Persistent.user_name;
        [textField resignFirstResponder];
    }
    
    return NO;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)save:(id)sender {
    
    
    
    NSURL *fileURL =  [NSURL URLWithString:assetsUrl];;
    NSLog(@"fileULR:%@",fileURL);
    
    if(fileURL){
        
        
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
        NSString *nowString = [formatter stringFromDate:now];
        
        NSString *imgFileForAPI = [NSString stringWithFormat:@"%@_%@",Persistent.user_id, nowString];
        NSString *imgFileForS3 = [NSString stringWithFormat:@"%@_%@.png", Persistent.user_id, nowString];
        
        [APIClient updateProfileBoth:username.text profile_img:imgFileForAPI handler:^(id result, NSUInteger code, NSError *error)
         {
             
             NSLog(@"result:%@",result);
             
             if (code != 200 || error != nil) {
                 return;
             }
             
             //API success case
             NSString *response_user = [result objectForKey:@"username"];
             NSString *response_img = [result objectForKey:@"profile_img"];
             if(![response_user isEqualToString:@"変更に失敗しました"])
             {
                 Persistent.user_name = [result objectForKey:@"username"];
             }
             
             
             AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
             expression.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@"progress:%f",(float)((double) totalBytesSent / totalBytesExpectedToSend));
                 });
             };
             
             NSLog(@"filename:%@",imgFileForAPI);
             
             AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // Do something e.g. Alert a user for transfer completion.
                     // On failed uploads, `error` contains the error object.
                     
                     if (![response_img isEqualToString:@"変更に失敗しました"])
                     {
                         Persistent.user_profile_image_url = [result objectForKey:@"profile_img"];
                         
                         [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[CompletePopup new]];
                         
                     }
                 });
             };
             
             AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility S3TransferUtilityForKey:@"gocci_up_north_east_1"];
             
             [[transferUtility uploadFile:fileURL
                                   bucket:@"gocci.imgs.provider.jp"
                                      key:imgFileForS3
                              contentType:@"image/png"
                               expression:expression
                         completionHander:completionHandler] continueWithBlock:^id(AWSTask *task) {
                 if (task.error) {
                     NSLog(@"Error: %@", task.error);
                 }
                 if (task.exception) {
                     NSLog(@"Exception: %@", task.exception);
                 }
                 if (task.result) {
                     NSLog(@"success:%@",task.result);
                 }
                 return nil;
             }];
             
         }];
    }else{
        
        [APIClient updateProfileOnlyUsername:username.text handler:^(id result, NSUInteger code, NSError *error)
         {
             NSLog(@"result:%@",result);
             
             if (code != 200 || error != nil) {
                 return;
             }
             NSString *response_user = [result objectForKey:@"username"];
             NSString *response_img = [result objectForKey:@"profile_img"];
             
             if(![response_user isEqualToString:@"変更に失敗しました"])
             {
                 Persistent.user_name = [result objectForKey:@"username"];
                 [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[CompletePopup new]];
             }
             else if (![response_img isEqualToString:@"変更に失敗しました"])
             {
                 Persistent.user_profile_image_url = [result objectForKey:@"profile_img"];
                 [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[CompletePopup new]];
             }
         }];
        
    }
}

- (void)showPopupWithTransitionStyle:(STPopupTransitionStyle)transitionStyle rootViewController:(UIViewController *)rootViewController
{
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:rootViewController];
    popupController.cornerRadius = 4;
    popupController.transitionStyle = transitionStyle;
    [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Cochin" size:17] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
}



@end
