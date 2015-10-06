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

@interface EditProfileViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    __weak IBOutlet UITextField *username;
    __weak IBOutlet UIImageView *userpicture;
    UIImagePickerController *ipc;
    NSString *assetsUrl;
    ALAssetsLibrary *library;
    NSURL *_groupURL;
    NSString *_AlbumName;
    //アルバムが写真アプリに既にあるかどうかの判定用
    BOOL _albumWasFound;
}


@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    username.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    [userpicture setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"avatarLink"]]
                placeholderImage:[UIImage imageNamed:@"default.png"]];
    userpicture.userInteractionEnabled = YES;
    userpicture.tag = 101;
    // Do any additional setup after loading the view.
    
    //ALAssetLibraryのインスタン作成
    library = [[ALAssetsLibrary alloc] init];
   
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
    NSLog(@"info:%@",info);
   
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //カメラロールにUIImageを保存する。保存完了後、completionBlockで「NSURL* assetURL」が取得できる
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation
                           completionBlock:^(NSURL* assetURL, NSError* error) {
                               NSLog(@"assetURL:%@",assetURL);
                           }];

}


//select canceled
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //cancelのとき。なにもしないで閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}

//画像の保存完了時に呼ばれるメソッド
-(void)targetImage:(UIImage*)image
didFinishSavingWithError:(NSError*)error contextInfo:(void*)context{
    
    if(error){
        // 保存失敗時
        NSLog(@"fail");
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        // 保存成功時
        NSLog(@"success");
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}

//tap 「保存」ボタン
- (void)save{
    
    // 現在時間を取得する
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
    NSString *nowString = [formatter stringFromDate:now];
    
    //ファイル名+user_id形式
    NSString *imgFileForS3 = [NSString stringWithFormat:@"%@_%@.jpg",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],nowString];
    
    //Fileurl
    NSURL *fileURL =  [NSURL URLWithString:assetsUrl];;
    
    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"progress:%f",(float)((double) totalBytesSent / totalBytesExpectedToSend));
        });
    };
    
    AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Do something e.g. Alert a user for transfer completion.
            // On failed uploads, `error` contains the error object.
        });
    };
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility S3TransferUtilityForKey:@"gocci_up_north_east_1"];
    [[transferUtility uploadFile:fileURL
                          bucket:@"gocci.imgs.provider.jp-test"
                             key:imgFileForS3
                     contentType:@"image/jpeg"
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

}

-(UIImage*)photoFromALAssets:(NSURL*)imageurl
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    
    __block UIImage* image = nil;
    //ALAssetsLibrary読み込みの待ち合わせ
    dispatch_async(queue,
                   ^{
                       [library assetForURL:imageurl
                                resultBlock: ^(ALAsset *asset)
                        {
                            ALAssetRepresentation *representation;
                            representation = [asset defaultRepresentation];
                            image = [[UIImage alloc] initWithCGImage:representation.fullResolutionImage];
                            dispatch_semaphore_signal(sema);
                        }
                               failureBlock:^(NSError *error) {
                                   NSLog(@"error:%@", error);
                                   dispatch_semaphore_signal(sema);
                               }];
                   });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return image;
}
    /*
     #pragma mark - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    @end
