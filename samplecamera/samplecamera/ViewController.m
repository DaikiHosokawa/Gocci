//
//  ViewController.m
//  samplecamera
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}



- (void)pushCameraBtn{
    if ([UIImagePickerController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //画面を生成
        UIImagePickerController *ipc =
        [[UIImagePickerController alloc ] init];
        
        //画像の取得先をカメラに設定(動画)
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        //ムービーモードにする(これが大切)
        ipc.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        
        //高画質にする
        ipc.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        //動画の最大撮影時間
        ipc.videoMaximumDuration = 6;
        
        //シャッターボタンを隠す
        ipc.showsCameraControls = NO;
        
        //デリゲートを自分自身に設定
        ipc.delegate = self;
        
        //モーダルビューとして呼び出す
        [self presentViewController:ipc animated:YES completion:nil];
}
}

-(void)recordCamera {
    NSLog(@"撮れてまっせ");
    // カメラの利用
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    // カメラが利用可能かチェック
    [UIImagePickerController isSourceTypeAvailable:sourceType];
        // インスタンスの作成
        UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
        cameraPicker.sourceType = sourceType;
        cameraPicker.delegate = self;
        
    [self presentViewController:cameraPicker animated:YES completion:nil];
}

- (void)stopCamera {
    NSLog(@"終わってまっせ");
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
}
//画像が選択された時の動作
-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    
    // モーダルビューを閉じる
    [self dismissModalViewControllerAnimated:YES];
    
   }


//保存完了時に読み込まれる動作
-(void)targetImage:(UIImage*)image
didFinishSavingWithError:(NSError*)error contextInfo:(void*)context{
    
    if(error){
        // 保存失敗時の処理
        NSLog(@"保存に失敗しました");
        
    }else{
        // 保存成功時の処理
        NSLog(@"保存に成功しました");
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    // モーダルビューを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 必要な処理を記述
}

//キャンセルしたところで呼ばれる
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self recordCamera];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self stopCamera];
    
}

@end
