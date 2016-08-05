//
//  LMCameraManager.m
//  Test1030
//
//  Created by xx11dragon on 15/10/30.
//  Copyright © 2015年 xx11dragon. All rights reserved.
//

#import "MPCameraManager.h"
#import "GPUImage.h"

@interface MPCameraManager ()<GPUImageMovieWriterDelegate>
{
    BOOL isMeiYanOpen;
}


//摄像机
@property (nonatomic , strong) GPUImageStillCamera *camera;

//摄像机显示层
@property (nonatomic , strong) GPUImageView *cameraScreen;

//录制视频存储
@property (nonatomic, strong)  GPUImageMovieWriter *movieWriter;

//焦点
@property (nonatomic, strong)  UIImageView *focusImageView;

//美颜滤镜
@property (nonatomic, strong)  GPUImageBeautifyFilter *beautifyFilter;

//默认空滤镜(没有无法保存图片)
@property (nonatomic, strong) GPUImageFilter *defineImageFilter;
@property (nonatomic, strong) NSMutableDictionary * videoSettings;
@property (nonatomic, strong) NSDictionary * audioSettings;

@end


@implementation MPCameraManager

- (id)initWithFrame:(CGRect)frame superview:(UIView *)superview {
    self = [super init];
    if (self) {
        
        isMeiYanOpen = NO;
        
        //创建摄像头
        _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
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
        
        //摄像头添加显示视图
        [_camera addTarget:_cameraScreen];
        
        [self rotateMeiYan:NO];
        
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
#pragma mark 摄像头
- (GPUImageStillCamera *)camera {
    
    if (!_camera) {
        _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480
                                                                          cameraPosition:AVCaptureDevicePositionBack];
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _camera.horizontallyMirrorFrontFacingCamera = YES;
    }
    return _camera;
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
    
    [self.camera capturePhotoAsImageProcessedUpToFilter:isMeiYanOpen?self.beautifyFilter:self.defineImageFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
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
    return self.camera.isFrontFacingCameraPresent;
}

//前后摄像头来回切换
- (void)rotateCamera
{
    [self.camera rotateCamera];
}

- (GPUImageBeautifyFilter *)beautifyFilter
{
    if (!_beautifyFilter) {
        _beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    }
    return _beautifyFilter;
}


- (GPUImageFilter *)defineImageFilter
{
    if (!_defineImageFilter) {
        _defineImageFilter = [[GPUImageFilter alloc] init];
    }
    return _defineImageFilter;
}

//是否开启美颜磨皮功能
- (void)rotateMeiYan:(BOOL)isMeiYan
{
    isMeiYanOpen = isMeiYan;
    if (!isMeiYan) {

        [self.camera removeAllTargets];
        [self.camera addTarget:self.defineImageFilter];
        [self.defineImageFilter addTarget:self.cameraScreen];
    }
    else {

        [self.camera removeAllTargets];

        [self.camera addTarget:self.beautifyFilter];
        [self.beautifyFilter addTarget:self.cameraScreen];
    }
}

- (void)startRecord:(NSString *)savePath
{
    
    //init Video Setting
    _videoSettings = [[NSMutableDictionary alloc] init];;
    [_videoSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [_videoSettings setObject:[NSNumber numberWithInteger:200] forKey:AVVideoWidthKey];
    [_videoSettings setObject:[NSNumber numberWithInteger:200] forKey:AVVideoHeightKey];
    
    //init audio setting
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    _audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                     [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                     [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,
                     [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,
                     [ NSData dataWithBytes:&channelLayout length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
                     [ NSNumber numberWithInt: 32000 ], AVEncoderBitRateKey,
                     nil];

    
    
    NSURL *willSaveURL = [NSURL fileURLWithPath:savePath];
    
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:willSaveURL size:CGSizeMake(480.0, 640.0) fileType:AVFileTypeMPEG4 outputSettings:nil];
//    _movieWriter.delegate = self;
//    [_movieWriter setHasAudioTrack:YES audioSettings:_audioSettings];
    
    if (isMeiYanOpen) {
        [self.beautifyFilter addTarget:_movieWriter];
    }
    else
    {
        [self.defineImageFilter addTarget:_movieWriter];
    }
    
    [_movieWriter startRecording];
    
    [_movieWriter setCompletionBlock:^{
        NSLog(@"录制成功");
    }];
}

- (void)stopRecord
{
    if (isMeiYanOpen) {
        [self.beautifyFilter removeTarget:_movieWriter];
    }
    else
    {
        [self.defineImageFilter removeTarget:_movieWriter];
    }
    
    [_movieWriter finishRecording];
}

- (void)movieRecordingCompleted
{
    
}
- (void)movieRecordingFailedWithError:(NSError*)error
{
    
}

@end
