//
//  LMCameraManager.m
//  Test1030
//
//  Created by xx11dragon on 15/10/30.
//  Copyright © 2015年 xx11dragon. All rights reserved.
//

#import "MPCameraManager.h"
#import "GPUImage.h"
#import "MPVideoProcessing.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MPCameraManager ()<GPUImageMovieWriterDelegate>

//摄像机
@property (nonatomic , strong) GPUImageStillCamera *camera;

//摄像机显示层
@property (nonatomic , strong) GPUImageView *cameraScreen;

//录制视频存储
@property (nonatomic, strong)  GPUImageMovieWriter *movieWriter;

//焦点
@property (nonatomic, strong)  UIImageView *focusImageView;


//普通滤镜
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *defaultFilter;
//美颜滤镜
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *meiYanFilter;
//当前滤镜
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *currentFilter;



//声音配置
@property (nonatomic, strong) NSDictionary * videoSettings;
@property (nonatomic, strong) NSDictionary * audioSettings;

@property (nonatomic, strong) NSTimer *countDurTimer;

//单个视频片段录制时间
@property (assign, nonatomic) CGFloat currentVideoDur;

//所有视频录制片段总时长
@property (assign ,nonatomic) CGFloat totalVideoDur;

@end


@implementation MPCameraManager


#pragma mark --
#pragma mark ---  视频滤镜 ----

//声音配置 －－option
- (NSDictionary *)audioSettings
{
    AudioChannelLayout channelLayout;
    
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    return  [NSDictionary dictionaryWithObjectsAndKeys:
                     
                     [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,//制定编码算法
                     
                     [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,//声道
                     
                     [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,//采样率
                     
                     [ NSData dataWithBytes:&channelLayout length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
                     
                     [ NSNumber numberWithInt: 32000 ], AVEncoderBitRateKey,//编码率
                     
                     nil];
    

}

//视频画面配置(宽高) －－option
- (NSDictionary *)videoSettings
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                AVVideoCodecH264, AVVideoCodecKey,
                [NSNumber numberWithInteger:640.0], AVVideoWidthKey,
                [NSNumber numberWithInteger:640.0], AVVideoHeightKey,
                nil];
    
}

//普通滤镜
- (GPUImageOutput<GPUImageInput> *)defaultFilter
{
    if (!_defaultFilter) {
        
        // Filter
        _defaultFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, (640.0-480.0)/2/640.0, 1,480.0/640.0)];
    }
    return _defaultFilter;
    
}
//美颜滤镜
- (GPUImageOutput<GPUImageInput> *)meiYanFilter
{
    if (!_meiYanFilter) {
        
        //Filters
        _meiYanFilter = [[GPUImageFilterGroup alloc] init];
        
        GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, (640.0-480.0)/2/640.0, 1,480.0/640.0)];
        [(GPUImageFilterGroup *)_meiYanFilter addTarget:cropFilter];
        
        GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
        [(GPUImageFilterGroup *)_meiYanFilter addTarget:beautifyFilter];
        
        //filter guan xi
        [cropFilter addTarget:beautifyFilter];
        
        [(GPUImageFilterGroup *)_meiYanFilter setInitialFilters:[NSArray arrayWithObject:cropFilter]];
        [(GPUImageFilterGroup *)_meiYanFilter setTerminalFilter:beautifyFilter];
        
        [(GPUImageFilterGroup *)_meiYanFilter useNextFrameForImageCapture];
        [(GPUImageFilterGroup *)_meiYanFilter forceProcessingAtSize:self.cameraScreen.frame.size];
    }
    return _meiYanFilter;
}

- (GPUImageOutput<GPUImageInput> *)currentFilter
{
    if (self.isMeiYan) {
        return self.meiYanFilter;
    }
    return self.defaultFilter;
}


#pragma mark -- initWithFrame ------


/**
 *  取得录音文件的设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSettion
{
//    AVAudioSession *sharedAudioSession = [AVAudioSession sharedInstance];
//    double preferredHardwareSampleRate;
//    
//    if ([sharedAudioSession respondsToSelector:@selector(sampleRate)])
//    {
//        preferredHardwareSampleRate = [sharedAudioSession sampleRate];
//    }
//    else
//    {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        preferredHardwareSampleRate = [[AVAudioSession sharedInstance] currentHardwareSampleRate];
//#pragma clang diagnostic pop
//    }
//
//    
//    
//    AudioChannelLayout acl;
//    bzero( &acl, sizeof(acl));
//    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
//    
//    return [NSDictionary dictionaryWithObjectsAndKeys:
//                           [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
//                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
//                           [ NSNumber numberWithFloat: preferredHardwareSampleRate ], AVSampleRateKey,
//                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
//                           //[ NSNumber numberWithInt:AVAudioQualityLow], AVEncoderAudioQualityKey,
//                           [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
//                           nil];
    
    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
            [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,
            [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
            nil];
}


- (id)initWithFrame:(CGRect)frame superview:(UIView *)superview {
    self = [super init];
    if (self) {

        
        //创建摄像头
        _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480
                                                      cameraPosition:AVCaptureDevicePositionBack];
        //输出图像旋转方式
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _camera.horizontallyMirrorFrontFacingCamera = YES;
        //防止录制第一针黑屏，必须初始化时添加
        [_camera addAudioInputsAndOutputs];
        
        //创建摄像头显示视图
        _cameraScreen = [[GPUImageView alloc] initWithFrame:frame];
        
        //显示模式充满整个边框
        _cameraScreen.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        _cameraScreen.clipsToBounds = YES;
        [_cameraScreen.layer setMasksToBounds:YES];
        

        //摄像头显示视图添加到父视图
        [superview addSubview:_cameraScreen];
        
        self.isMeiYan = NO;
        
    }
    return self;
}


#pragma mark 启用预览
- (void)startCamera{
    [self.camera startCameraCapture];
    
    if ([self.camera.inputCamera isFocusPointOfInterestSupported] && [self.camera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([self.camera.inputCamera lockForConfiguration:&error]) {
            [self.camera.inputCamera setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
            
            [self.camera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([self.camera.inputCamera isExposurePointOfInterestSupported] && [self.camera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [self.camera.inputCamera setExposurePointOfInterest:CGPointMake(0.5, 0.5)];
                [self.camera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [self.camera.inputCamera unlockForConfiguration];
            
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
}

#pragma mark 关闭预览
- (void)stopCamera{
    [self.camera stopCameraCapture];
    

    
}



- (UIImageView *)focusImageView
{
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.cameraScreen.layer addSublayer:_focusImageView.layer];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focus:)];
        [self.cameraScreen addGestureRecognizer:tap];
        
    }
    return _focusImageView;
}

#pragma mark 设置对焦图片
- (void)setFocusImageName:(NSString *)focusImageName
{

    UIImage *focusImage = [UIImage imageNamed:focusImageName];
    self.focusImageView.frame = CGRectMake(0, 0, focusImage.size.width, focusImage.size.height);
    self.focusImageView.image = focusImage;
    self.focusImageView.hidden = YES;
}

#pragma mark 摄像头位置
- (void)setPosition:(AVCaptureDevicePosition)position {
    switch (position) {
        case AVCaptureDevicePositionBack: {
            if (self.camera.cameraPosition != AVCaptureDevicePositionBack) {
                [self.camera pauseCameraCapture];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    // something
                    [self.camera rotateCamera];
                    [self.camera resumeCameraCapture];
                    
                });
            }

        }
            
            break;
        case AVCaptureDevicePositionFront: {
            if (self.camera.cameraPosition != AVCaptureDevicePositionFront) {
                [self.camera pauseCameraCapture];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    // something
                    [self.camera rotateCamera];
                    [self.camera resumeCameraCapture];
                    
                });
    
            }
        }

            break;
        default:
            break;
    }
}

- (void) animationCamera {
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromRight;
    [self.cameraScreen.layer addAnimation:animation forKey:nil];
    
}


#pragma mark 闪光灯

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    [self.camera.inputCamera lockForConfiguration:nil];
    [self.camera.inputCamera setTorchMode:torchMode];
    [self.camera.inputCamera unlockForConfiguration];
}

#pragma mark 对焦

- (void)focus:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:tap.view];
    [self layerAnimationWithPoint:touchPoint];
    touchPoint = CGPointMake(touchPoint.x / tap.view.bounds.size.width, touchPoint.y / tap.view.bounds.size.height);

    if ([self.camera.inputCamera isFocusPointOfInterestSupported] && [self.camera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([self.camera.inputCamera lockForConfiguration:&error]) {
            [self.camera.inputCamera setFocusPointOfInterest:touchPoint];
            
            [self.camera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([self.camera.inputCamera isExposurePointOfInterestSupported] && [self.camera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [self.camera.inputCamera setExposurePointOfInterest:touchPoint];
                [self.camera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [self.camera.inputCamera unlockForConfiguration];
            
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
}

//- (void)focusAtPoint:(CGPoint)touchPoint
//{
//    [self layerAnimationWithPoint:touchPoint];
//    touchPoint = CGPointMake(touchPoint.x / tap.view.bounds.size.width, touchPoint.y / tap.view.bounds.size.height);
//    
//    if ([self.camera.inputCamera isFocusPointOfInterestSupported] && [self.camera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//        NSError *error;
//        if ([self.camera.inputCamera lockForConfiguration:&error]) {
//            [self.camera.inputCamera setFocusPointOfInterest:touchPoint];
//            
//            [self.camera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
//            
//            if([self.camera.inputCamera isExposurePointOfInterestSupported] && [self.camera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
//            {
//                [self.camera.inputCamera setExposurePointOfInterest:touchPoint];
//                [self.camera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
//            }
//            
//            [self.camera.inputCamera unlockForConfiguration];
//            
//        } else {
//            NSLog(@"ERROR = %@", error);
//        }
//    }
//
//}

#pragma mark 对焦动画
- (void)layerAnimationWithPoint:(CGPoint)point {
    if (_focusImageView) {
        
        CALayer *focusLayer = _focusImageView.layer;
        [focusLayer removeAllAnimations];
        focusLayer.hidden = NO;
        [focusLayer setPosition:point];
       
        
        CAAnimationGroup *focusAniGroup = [CAAnimationGroup animation];
        focusAniGroup.animations = [NSArray arrayWithObjects:[self animationBigSmall], [self animationTwinkle], nil];
        focusAniGroup.delegate = self;
        focusAniGroup.duration = 2.0;
        [_focusImageView.layer addAnimation:focusAniGroup forKey:@"animations"];
        
    }
}

//放大变小
- (CAAnimation *)animationBigSmall
{
    // 设定为缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];

    // 动画选项设定
    animation.duration = 0.3; // 动画持续时间
    animation.repeatCount = 1; // 重复次数
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:0.9]; // 结束时的倍率
    animation.autoreverses = YES; // 动画结束时执行逆动画
    return animation;
}

//闪烁动画
- (CAAnimation *)animationTwinkle
{
    CABasicAnimation *animationn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationn.duration = 0.3; // 动画持续时间
    animationn.repeatCount = 2; // 重复次数
    animationn.beginTime = 0.6;
    animationn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    animationn.fromValue = [NSNumber numberWithFloat:1.0];
    animationn.toValue = [NSNumber numberWithFloat:0.5];
    animationn.autoreverses = YES; // 动画结束时执行逆动画
    return animationn;
}


#pragma mark - AnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
       self.focusImageView.hidden = YES;
    }
    
}

#pragma mark 拍照

- (void)snapshotSuccess:(void(^)(UIImage *image))success
        snapshotFailure:(void (^)(void))failure {
    
//    GPUImageFilter *ddd = [[GPUImageFilter alloc] init];
    
//    [self.camera capturePhotoAsImageProcessedUpToFilter:self.currentFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
//        
//        if (!processedImage){
//            failure();
//        }else {
//
//            //处理裁剪到指定分辨率
//            CGFloat prop = processedImage.size.width/_cameraScreen.size.width;
//            CGFloat newHeight = _cameraScreen.size.height * prop;
//            CGFloat cutY = (processedImage.size.height-newHeight)/2;
//            
//            CGImageRef newimageRef = CGImageCreateWithImageInRect([processedImage CGImage], CGRectMake(0, cutY, processedImage.size.width, newHeight));
//            UIImage *newImage = [UIImage imageWithCGImage:newimageRef];
//            
//            success(newImage);
//        }
//
//    }];
//
}



//是否开启闪光灯
- (void)rotateFlashLight:(BOOL)isFlashLight
{
    if (isFlashLight) {
        self.torchMode = AVCaptureTorchModeOn;
    }else
    {
        self.torchMode = AVCaptureTorchModeOff;
    }
}

- (BOOL)isFrontCamera
{
    return self.camera.isFrontCamera;
}

//前后摄像头来回切换
- (void)rotateCamera
{
    [self.camera rotateCamera];
}

//是否开启美颜磨皮功能
- (void)setIsMeiYan:(BOOL)isMeiYan
{
    _isMeiYan = isMeiYan;
    
    [self.camera removeAllTargets];
    if (!isMeiYan) {
        [self.camera addTarget:self.defaultFilter];
        [self.defaultFilter addTarget:self.cameraScreen];
    }
    else {

        [self.camera addTarget:self.meiYanFilter];
        [self.meiYanFilter addTarget:self.cameraScreen];
    }
}


- (void)setIsFlashLight:(BOOL)isFlashLight
{
    _isFlashLight = isFlashLight;
    if (isFlashLight) {
        [self.camera.inputCamera lockForConfiguration:nil];
        [self.camera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        [self.camera.inputCamera unlockForConfiguration];
    }else
    {
        [self.camera.inputCamera lockForConfiguration:nil];
        [self.camera.inputCamera setTorchMode:AVCaptureTorchModeOff];
        [self.camera.inputCamera unlockForConfiguration];
    }
}

#pragma  mark --
#pragma  mark ---------- video record --------

/**
 *  设置音频会话
 *
 */

-(void)setAudioSession
{
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    //设置为播放和录制状态，以便在录制完成之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}
- (NSURL *)getSavaPath

{
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:@"aaaa.caf"];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}
- (void)startRecord:(NSString *)savePath
{
    self.isRecording = YES;
    
    //开始记录当前录制时长
    [self startCountDurTimer];
    
    //响应开始录制代理方法
    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:[NSURL new]];
    }
    
    //配置录制器
    NSURL *willSaveURL = [NSURL fileURLWithPath:savePath];
    
//    [self setAudioSession];
//    //创建录音文件保存路径
//
//    
//    
//    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
//            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
//                if (granted) {
//                    NSLog(@"ok");
//                } else {
//                    NSLog(@"no");
//                }
//            }];
//        }
//    }
    
    NSURL *audiorecordURL = [NSURL fileURLWithPath:[savePath stringByReplacingOccurrencesOfString:@"mp4" withString:@"caf"]];

    //创建录音机
    NSError * error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:audiorecordURL settings:[self getAudioSettion] error:&error];
//    _audioRecorder.delegate = self;
//    _audioRecorder.meteringEnabled = YES;
    [_audioRecorder prepareToRecord];

    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:willSaveURL size:CGSizeMake(640.0, 640.0)];
    
//    [_movieWriter setHasAudioTrack:YES audioSettings:self.audioSettings];
    
////    开启声音采集
//    _movieWriter.encodingLiveVideo = YES;
//    _movieWriter.shouldPassthroughAudio = YES;
//    _movieWriter.hasAudioTrack=YES;

    
    //设置录制视频滤镜
    [self.currentFilter addTarget:_movieWriter];
    
//    //设置声音解析对象
//    self.camera.audioEncodingTarget = _movieWriter;
    
    [_audioRecorder record];
    //开始录制
    [_movieWriter startRecording];

  
    
    //录制完毕回调
    __weak MPCameraManager *weakSelf = self;
    [weakSelf.movieWriter setCompletionBlock:^{
        NSLog(@"录制成功");
        
        self.totalVideoDur += _currentVideoDur;
        NSLog(@"本段视频长度: %f", _currentVideoDur);
        NSLog(@"现在的视频总长度: %f", _totalVideoDur);
        
        if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
            [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:nil duration:_currentVideoDur totalDur:_totalVideoDur error:nil];
        }
        
        
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        [library writeVideoAtPathToSavedPhotosAlbum:willSaveURL
//                                    completionBlock:^(NSURL *assetURL, NSError *error) {
//                                        if (error) {
//                                            NSLog(@"Save video fail:%@",error);
//                                        } else {
//                                            NSLog(@"Save video succeed.");
//                                        }
//                                    }];
        
        
    }];
    
    
}


- (void)startCountDurTimer
{
    self.countDurTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)timer
{
    
    self.currentVideoDur += COUNT_DUR_TIMER_INTERVAL;
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didRecordingToOutPutFileAtURL:duration:recordedVideosTotalDur:)]) {
        [_delegate videoRecorder:self didRecordingToOutPutFileAtURL:nil duration:_currentVideoDur recordedVideosTotalDur:_totalVideoDur];
    }
    
    if (_totalVideoDur + _currentVideoDur >= MAX_VIDEO_DUR) {
        [self stopCurrentVideoRecording];
    }
    
}

- (void)stopCurrentVideoRecording
{
    [self stopCountDurTimer];
    [self stopRecord];
}


- (void)stopCountDurTimer
{
    [_countDurTimer invalidate];
    self.countDurTimer = nil;
}


- (void)stopRecord
{
    self.isRecording = NO;
    
    [self stopCountDurTimer];
    self.currentVideoDur = 0.0f;

    [self.currentFilter removeTarget:_movieWriter];
    
    [_audioRecorder stop];
    [_movieWriter finishRecording];
    

    
//    if (!error) {
//        SBVideoData *data = [[SBVideoData alloc] init];
//        data.duration = _currentVideoDur;
//        data.fileURL = outputFileURL;
//        
//        [_videoFileDataArray addObject:data];
//    }
    
//    if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
//        [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:outputFileURL duration:_currentVideoDur totalDur:_totalVideoDur error:error];
//    }
    
}


- (NSInteger)getVideoCount
{
    NSArray *clips = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:ClipsDictionaryPath error:nil];
    return clips.count;
}


- (void)mergeVideoFiles
{
    NSMutableArray *fileURLArray = [[NSMutableArray alloc] init];
    NSArray *clips = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:ClipsDictionaryPath error:nil];
    [clips enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([fileName containsString:@".mp4"]) {
            NSString *filePath = [ClipsDictionaryPath stringByAppendingPathComponent:fileName];
            NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
            [fileURLArray addObject:filePathURL];
        }
      
    }];
    

    [[MPVideoProcessing shareInstance] mergeAndExportVideos:fileURLArray bgMusicURL:self.musicFilePath?[NSURL fileURLWithPath:self.musicFilePath]:nil isG:NO completionHandler:^(NSURL *mergeFileURL) {
        if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
            [_delegate videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
        }
    }];
}

- (void)deleteLastVideo
{
    NSArray *clips = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:ClipsDictionaryPath error:nil];
    
    if (clips.count <= 0) {
        return;
    }
    
    //delete
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [ClipsDictionaryPath stringByAppendingPathComponent:[clips lastObject]] ;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:filePath error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //delegate
                if ([_delegate respondsToSelector:@selector(videoRecorder:didRemoveVideoFileAtURL:totalDur:error:)]) {
                    [_delegate videoRecorder:self didRemoveVideoFileAtURL:[NSURL fileURLWithPath:filePath] totalDur:_totalVideoDur error:error];
                }
            });
        }
    });

}

- (void)clearAllClips
{
    NSArray *clips = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:ClipsDictionaryPath error:nil];
    
    if (clips.count <= 0) {
        return;
    }
    
    //delete
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [clips enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *filePath = [ClipsDictionaryPath stringByAppendingPathComponent:fileName];
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            
        }];
    });
}

@end
