//
//  EditProfileViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/06.
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
    NSLog(@"username:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]);
    username.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    username.delegate = self;
   // [userpicture setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"avatarLink"]]
     //           placeholderImage:[UIImage imageNamed:@"default.png"]];
    
    // 画像の作成3．Web上の画像を作成
    NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"avatarLink"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    userpicture.image = image;
    NSLog(@"picturein:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"avatarLink"]);
    userpicture.userInteractionEnabled = YES;
    userpicture.tag = 101;
    
    save.layer.cornerRadius = 3;
    save.clipsToBounds = YES;
    
    background.layer.borderColor = [UIColor grayColor].CGColor;
    
    background.layer.borderWidth = 1;
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//tap picture
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ( touch.view.tag == userpicture.tag )
        [self clickLogo:userpicture];
}


//tap picture method
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


//select image from camera-roll
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *ImgData = UIImagePNGRepresentation(editedImage);
        [ImgData writeToFile:imagePath atomically:YES];
        //image set
        userpicture.image = editedImage;
    }
    //url set
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
        username.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        [textField resignFirstResponder];
    }
    
    return NO;
}


//select canceled
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //cancelのとき。なにもしないで閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}

//tap 「保存」ボタン
- (IBAction)save:(id)sender {
    
    
    
    NSURL *fileURL =  [NSURL URLWithString:assetsUrl];;
    NSLog(@"fileULR:%@",fileURL);
    
    //check Image is chenged
    
    if(fileURL){
        
        //Image is chenged
        
        // 現在時間を取得する
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
        NSString *nowString = [formatter stringFromDate:now];
        
        //ファイル名+user_id形式
        NSString *imgFileForAPI = [NSString stringWithFormat:@"%@_%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],nowString];
        NSString *imgFileForS3 = [NSString stringWithFormat:@"%@_%@.png",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],nowString];
        
        [APIClient updateProfileBoth:username.text profile_img:imgFileForAPI handler:^(id result, NSUInteger code, NSError *error)
         {
             
             NSLog(@"result:%@",result);
             
             if (code != 200 || error != nil) {
                 // API からのデータの取得に失敗
                 // TODO: アラート等を掲出
                 return;
             }
             
             //API success case
             NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
             NSString *response_user = [result objectForKey:@"username"];
             NSString *response_img = [result objectForKey:@"profile_img"];
             if(![response_user isEqualToString:@"変更に失敗しました"])
             {
                 [ud setValue:[result objectForKey:@"username"] forKey:@"username"];
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
                         [ud setValue:[result objectForKey:@"profile_img"] forKey:@"avatarLink"];
                         [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[CompletePopup new]];
                         
                     }
                 });
             };
             
             AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility S3TransferUtilityForKey:@"gocci_up_north_east_1"];
             
             [[transferUtility uploadFile:fileURL
                                   bucket:@"gocci.imgs.provider.jp-test"
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
                     AWSS3TransferUtilityUploadTask *uploadTask = task.result;
                     NSLog(@"success:%@",task.result);
                     // Do something with uploadTask.
                 }
                 return nil;
             }];
             
         }];
    }else{
        
        //image is not chenged
        
        [APIClient updateProfileOnlyUsername:username.text handler:^(id result, NSUInteger code, NSError *error)
         {
             NSLog(@"result:%@",result);
             
             if (code != 200 || error != nil) {
                 // API からのデータの取得に失敗
                 // TODO: アラート等を掲出
                 return;
             }
             //API success case
             NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
             
             NSString *response_user = [result objectForKey:@"username"];
             NSString *response_img = [result objectForKey:@"profile_img"];
             
             if(![response_user isEqualToString:@"変更に失敗しました"])
             {
                 [ud setValue:[result objectForKey:@"username"] forKey:@"username"];
                 [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[CompletePopup new]];
             }
             else if (![response_img isEqualToString:@"変更に失敗しました"])
             {
                 [ud setValue:[result objectForKey:@"profile_img"] forKey:@"avatarLink"];
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
    // !!!:dezamisystem
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
}



@end
