//
//  CamaeraViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/11.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "CamaeraViewController.h"

@interface CamaeraViewController ()
{
    CALayer* previewLayer;
    bool isPause, isRecording, isWritting;
    AVAssetWriter* writer;
    AVAssetWriterInput* videoWriterInput;
    AVCaptureSession *session;
    int writeFrames;
    AVCaptureVideoPreviewLayer* captureVideoPreviewLayer;
}

@end

@implementation CamaeraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeSession];
    
    if (previewLayer == nil) {
        previewLayer = [self.previewWindow layer];
    }
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    captureVideoPreviewLayer.frame = previewLayer.bounds;
    
    [previewLayer addSublayer:captureVideoPreviewLayer];
}


- (void)makeSession
{
    session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    [device lockForConfiguration:nil];
    device.activeVideoMinFrameDuration = CMTimeMake(1, 30);
    [device unlockForConfiguration];
    
    [session addInput:videoInput];
    
    AVCaptureVideoDataOutput* videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:videoDataOutput];
    
    videoDataOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],kCVPixelBufferPixelFormatTypeKey,
                                     nil];
    
    //----- 解説-1 -----
    dispatch_queue_t videoQueue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoQueue];
    
    AVCaptureConnection* videoConnection = nil;
    for ( AVCaptureConnection *connection in [videoDataOutput connections] )
    {
        NSLog(@"%@", connection);
        for ( AVCaptureInputPort *port in [connection inputPorts] )
        {
            NSLog(@"%@", port);
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
            }
        }
    }
    
    
    [session startRunning];
}

- (void)removeSession
{
    [session stopRunning];
}

- (void)makeWriter
{
    NSString *pathString = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/capture.mov"];
    NSURL* exportURL = [NSURL fileURLWithPath:pathString];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportURL.path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportURL.path error:nil];
    }
    
    NSError* error;
    writer = [[AVAssetWriter alloc] initWithURL:exportURL
                                       fileType:AVFileTypeQuickTimeMovie
                                          error:&error];
    
    NSDictionary* videoSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                  AVVideoCodecH264, AVVideoCodecKey,
                                  [NSNumber numberWithInt:1080], AVVideoWidthKey,
                                  [NSNumber numberWithInt:1920], AVVideoHeightKey,
                                  nil];
    videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                          outputSettings:videoSetting];
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    [writer addInput:videoWriterInput];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if ((isPause) && (isRecording)) { return; }
    if( !CMSampleBufferDataIsReady(sampleBuffer) )
    {
        NSLog( @"sampleBufferの準備ができていません" );
        return;
    }
    
    if( isRecording == YES ) {
        isWritting = YES;
        NSLog(@"recording");
        if( writer.status != AVAssetWriterStatusWriting  ) {
            [writer startWriting];
           
            [writer startSessionAtSourceTime:kCMTimeZero];
        }
        
        if( [videoWriterInput isReadyForMoreMediaData] ) {
            CFRetain(sampleBuffer);
            CMSampleBufferRef newSampleBuffer = [self offsetTimmingWithSampleBufferForVideo:sampleBuffer];
            [videoWriterInput appendSampleBuffer:newSampleBuffer];
            CFRelease(sampleBuffer);
            CFRelease(newSampleBuffer);
        }
       
        writeFrames++;
        
    } else {
        if( writer.status == AVAssetWriterStatusWriting  ) {
            if (isWritting) {
                [writer finishWritingWithCompletionHandler:^{
                    NSLog(@"finish");
                    NSString *pathString = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/capture.mov"];
                    NSURL* exportURL = [NSURL fileURLWithPath:pathString];
                    ALAssetsLibrary* al = [[ALAssetsLibrary alloc] init];
                    __weak id weakSelf = self;
                    __weak AVCaptureVideoPreviewLayer* weakPreviewLayer =  captureVideoPreviewLayer;
                    [al writeVideoAtPathToSavedPhotosAlbum:exportURL
                                           completionBlock:^(NSURL *assetURL, NSError *assetError) {
                                               if (assetError) {
                                                   NSLog(@"export error!!!!");
                                               }
                                               
                                               NSFileManager *manager = [NSFileManager defaultManager];
                                               if ([manager fileExistsAtPath:assetURL.absoluteString isDirectory:NO]) {
                                                   [manager removeItemAtPath:assetURL.absoluteString error:nil];
                                               }
                                               [weakSelf removeSession];
                                               writer = nil;
                                               [weakSelf makeSession];
                                               weakPreviewLayer.session = session;
                                           }];
                }];
            }
            isWritting = NO;
        }
    }
}


- (CMSampleBufferRef)offsetTimmingWithSampleBufferForVideo:(CMSampleBufferRef)sampleBuffer
{
    CMSampleBufferRef newSampleBuffer;
    CMSampleTimingInfo sampleTimingInfo;
    sampleTimingInfo.duration = CMTimeMake(1, 30);
    sampleTimingInfo.presentationTimeStamp = CMTimeMake(writeFrames, 30);
    sampleTimingInfo.decodeTimeStamp = kCMTimeInvalid;
    
    CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault,
                                          sampleBuffer,
                                          1,
                                          &sampleTimingInfo,
                                          &newSampleBuffer);
    
    return newSampleBuffer;
}

- (IBAction)startCapture
{
    [self makeWriter];
    isRecording = YES;
    isPause = NO;
    writeFrames = 0;
}

- (IBAction)pauseCapture
{
    if (isPause) {
        isPause = NO;
    } else {
        isPause = YES;
    }
}

- (IBAction)endCapture
{
    isRecording = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
