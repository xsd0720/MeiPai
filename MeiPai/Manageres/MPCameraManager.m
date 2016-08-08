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
                [NSNumber numberWithInteger:200], AVVideoWidthKey,
                [NSNumber numberWithInteger:200], AVVideoHeightKey,
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

- (id)initWithFrame:(CGRect)frame superview:(UIView *)superview {
    self = [super init];
    if (self) {
        
        
        //创建摄像头
        _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480
                                                      cameraPosition:AVCaptureDevicePositionBack];
        //输出图像旋转方式
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _camera.horizontallyMirrorFrontFacingCamera = YES;
        
        //创建摄像头显示视图
        _cameraScreen = [[GPUImageView alloc] initWithFrame:frame];
        
        //显示模式充满整个边框
        _cameraScreen.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        _cameraScreen.clipsToBounds = YES;
        [_cameraScreen.layer setMasksToBounds:YES];
        
        //摄像头显示视图添加到父视图
        [superview addSubview:_cameraScreen];
        
        self.isMeiYan = YES;
        
    }
    return self;
}


#pragma mark 启用预览
- (void)startCamera{
    [self.camera startCameraCapture];
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
    
    [self.camera capturePhotoAsImageProcessedUpToFilter:self.currentFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
        if (!processedImage){
            failure();
        }else {

            //处理裁剪到指定分辨率
            CGFloat prop = processedImage.size.width/_cameraScreen.size.width;
            CGFloat newHeight = _cameraScreen.size.height * prop;
            CGFloat cutY = (processedImage.size.height-newHeight)/2;
            
            CGImageRef newimageRef = CGImageCreateWithImageInRect([processedImage CGImage], CGRectMake(0, cutY, processedImage.size.width, newHeight));
            UIImage *newImage = [UIImage imageWithCGImage:newimageRef];
            
            success(newImage);
        }

    }];

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


#pragma  mark --
#pragma  mark ---------- video record --------

- (void)startRecord:(NSString *)savePath
{
    self.isRecording = YES;
    
    //配置录制器
    NSURL *willSaveURL = [NSURL fileURLWithPath:savePath];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:willSaveURL size:CGSizeMake(640.0, 640.0)];
    
    //开启声音采集
    _movieWriter.hasAudioTrack = YES;
    [self.camera addAudioInputsAndOutputs];
    self.camera.audioEncodingTarget = _movieWriter;
    
    //设置录制视频滤镜
    [self.currentFilter addTarget:_movieWriter];
    
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
    }];
    
    //开始记录当前录制时长
    [self startCountDurTimer];
    
    //响应开始录制代理方法
    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:willSaveURL];
    }
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
        NSString *filePath = [ClipsDictionaryPath stringByAppendingPathComponent:fileName];
        NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
        [fileURLArray addObject:filePathURL];
        
    }];
    [self mergeAndExportVideosAtFileURLs:fileURLArray];
}

- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray
{
    NSError *error = nil;
    
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    //先去assetTrack 也为了取renderSize
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileURLArray) {
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        
        if (!asset) {
            continue;
        }
        
        [assetArray addObject:asset];
        
        AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [assetTrackArray addObject:assetTrack];
        
        renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:totalDuration
                              error:nil];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
        
        //fix orientationissue
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
//        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影响
//        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        //data
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    //get save path
    NSURL *mergeFileURL = [NSURL fileURLWithPath:[NSString getVideoMergeFilePathString]];
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
                    [_delegate videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
                }
        });
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
