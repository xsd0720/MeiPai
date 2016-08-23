//
//  CameraHelp.m
//
//
//  Created by zcx. on 11-6-28.
//  Copyright 2011  . All rights reserved.
//

#import "CameraHelp.h"
//
//    Private
//
@interface CameraHelp (Private)

#if PRODUCER_HAS_VIDEO_CAPTURE
+(AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position;
- (void)startPreview;
- (void)stopPreview;
#endif

@end

@implementation CameraHelp (Private)

#if PRODUCER_HAS_VIDEO_CAPTURE
+ (AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras){
        if (device.position == position){
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (void)startPreview{
    if(mCaptureSession && mPreview && mStarted){
        AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: mCaptureSession];
        previewLayer.frame = mPreview.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        //        if(previewLayer.orientationSupported){
        //            previewLayer.orientation = mOrientation;
        //        }
        [mPreview.layer addSublayer: previewLayer];
        
        if(![mCaptureSession isRunning]){
            [mCaptureSession startRunning];
        }
    }
}

- (void)stopPreview{
    if(mCaptureSession){
        if([mCaptureSession isRunning]){
            [mCaptureSession stopRunning];
            
            // remove all sublayers
            if(mPreview){
                for(CALayer *ly in mPreview.layer.sublayers){
                    if([ly isKindOfClass: [AVCaptureVideoPreviewLayer class]])
                    {
                        [ly removeFromSuperlayer];
                        break;
                    }
                }
            }
        }
    }
}
#endif
@end

@implementation CameraHelp
static CameraHelp* g_camera = 0;
- (id)init
{
    if(g_camera)
        return g_camera;
    else
    {
        if(self = [super init])
        {
            self->mWidth = 30;
            self->mHeight = 30;
            
            self->mFps = 60;
            self->mFrontCamera = NO;
            self->mStarted = NO;
            g_camera = self;
            outDelegate = nil;
        }
        return g_camera;
    }
}
-(void)dealloc
{
#if PRODUCER_HAS_VIDEO_CAPTURE
    [mCaptureSession release];
    [mCaptureDevice release];
    [mPreview release];
#endif

}
+ (CameraHelp*)shareCameraHelp
{
    if(!g_camera)
        g_camera = [[CameraHelp alloc] init];
    return g_camera;
}
+ (void)closeCamera
{
    if(g_camera)
    {
    
        g_camera = nil;
    }
}
- (void)prepareVideoCapture:(int) width andHeight: (int)height andFps: (int) fps andFrontCamera:(BOOL) bfront andPreview:(UIView*) view
{
    self->mWidth = width;
    self->mHeight = height;
    self->mFps = fps;
    self->mFrontCamera = bfront;
    if(view)
        self->mPreview = view;
#if PRODUCER_HAS_VIDEO_CAPTURE
    if([mCaptureSession isRunning])
    {
        [self stopVideoCapture];
        [self startVideoCapture];
    }
#endif
}
- (void)startVideoCapture
{
#if PRODUCER_HAS_VIDEO_CAPTURE
    //防锁
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //打开摄像设备，并开始捕抓图像
    //[labelState setText:@"Starting Video stream"];
    if(mCaptureDevice || mCaptureSession)
    {
        NSLog(@"Already capturing");
        return;
    }
    
    if((mCaptureDevice = [CameraHelp cameraAtPosition:mFrontCamera? AVCaptureDevicePositionFront:AVCaptureDevicePositionBack]) == nil)
    {
        NSLog(@"Failed to get valide capture device");
        return;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:mCaptureDevice error:&error];
    if (!videoInput)
    {
        NSLog(@"Failed to get video input");
        mCaptureDevice = nil;
        return;
    }
    
    mCaptureSession = [[AVCaptureSession alloc] init];
    
    mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    [mCaptureSession addInput:videoInput];
    
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are
    // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA.
    // On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.
    //
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* settings = [NSDictionary dictionaryWithObject:value forKey:key];
    //    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
    //                              //[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], //kCVPixelBufferPixelFormatTypeKey,
    //                              [NSNumber numberWithInt: mWidth], (id)kCVPixelBufferWidthKey,
    //                              [NSNumber numberWithInt: mHeight], (id)kCVPixelBufferHeightKey,
    //                              nil];
    
    avCaptureVideoDataOutput.videoSettings = settings;
    //[settings release];
    //    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, 1.0f/30);
    avCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    
    
    dispatch_queue_t queue = dispatch_queue_create("com.gh.cecall", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [mCaptureSession addOutput:avCaptureVideoDataOutput];
    [settings release];
    [avCaptureVideoDataOutput release];
    dispatch_release(queue);
    mFirstFrame = YES;
    mStarted = YES;
    
    //start preview
    [self startPreview];
    
#endif
}
- (void)stopVideoCapture
{
#if PRODUCER_HAS_VIDEO_CAPTURE
    if(mCaptureSession){
        [mCaptureSession stopRunning];
        [mCaptureSession release], mCaptureSession = nil;
        NSLog(@"Video capture stopped");
    }
    [mCaptureDevice release], mCaptureDevice = nil;
    
    if(mPreview){
        for (UIView *view in mPreview.subviews) {
            [view removeFromSuperview];
        }
    }
#endif
}



- (BOOL)setFrontCamera
{
    if(mFrontCamera)
        return YES;
    [self stopVideoCapture];
    mFrontCamera = YES;
    [self startVideoCapture];
    return YES;
}

- (BOOL)setBackCamera{
    if(!mFrontCamera)
        return YES;
    [self stopVideoCapture];
    mFrontCamera = NO;
    [self startVideoCapture];
    return YES;
}

- (void) setPreview: (UIView*)preview{
#if PRODUCER_HAS_VIDEO_CAPTURE
    if(preview == nil){
        // stop preview
        [self stopPreview];
        // remove layers
        if(mPreview){
            for(CALayer *ly in mPreview.layer.sublayers){
                if([ly isKindOfClass: [AVCaptureVideoPreviewLayer class]]){
                    [ly removeFromSuperlayer];
                    break;
                }
            }
            [mPreview release], mPreview = nil;
        }
    }
    else {
        //start preview
        if (mPreview) {
            [mPreview release];
            mPreview = nil;
        }
        if((mPreview = [preview retain])){
            [self startPreview];
        }
    }
    
#endif
}
- (void)setVideoDataOutputBuffer:(id<CameraHelpDelegate>)delegate
{
    outDelegate = delegate;
}
#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
#if PRODUCER_HAS_VIDEO_CAPTURE
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    if (outDelegate) {
        [outDelegate getSampleBufferImage:image];
    }
#if 0
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //捕捉数据输出 要怎么处理虽你便
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess)
    {
        //        void *bufferPtr = CVPixelBufferGetBaseAddress(imageBuffer);
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer,0);
        size_t buffeSize = CVPixelBufferGetDataSize(imageBuffer);
        NSLog(@"%ld",buffeSize);
        if(self->mFirstFrame)
        {
            //第一次数据要求：宽高，类型
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
            size_t width = CVPixelBufferGetWidth(imageBuffer);
            size_t height = CVPixelBufferGetHeight(imageBuffer);
            NSNumber *numberRow = [NSNumber numberWithInteger:bytesPerRow];
            NSNumber *numberWidth = [NSNumber numberWithInteger:width];
            NSNumber *numberHeight = [NSNumber numberWithInteger:height];
            
            NSArray *array = [NSArray arrayWithObjects:numberRow,numberWidth,numberHeight, nil];
            
            if (outDelegate) {
                [outDelegate getVideoSizeInfo:array];
            }
            int pixelFormat = CVPixelBufferGetPixelFormatType(imageBuffer);
            switch (pixelFormat) {
                case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
                    //engine->srcFormat = VideoFormat_NV12;//PIX_FMT_NV12;
                    NSLog(@"Capture pixel format=NV12");
                    break;
                case kCVPixelFormatType_422YpCbCr8:
                    //engine->srcFormat = VideoFormat_UYVY;//PIX_FMT_UYVY422;
                    NSLog(@"Capture pixel format=UYUY422");
                    break;
                default:
                    //engine->srcFormat = VideoFormat_BGR32;//PIX_FMT_RGB32;
                    NSLog(@"Capture pixel format=RGB32");
            }
            mFirstFrame = NO;
        }
        //send data
        //engine->SendVideoFrame((unsigned char*)bufferPtr,buffeSize);
        if(outDelegate){
            [outDelegate videoDataOutputBuffer:(char*)bufferPtr dataSize:buffeSize];
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    [pool release];
#endif
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

#endif
@end
/**
-----------------------------------将图片保存为视频-------------------------------
- (void) saveVideo {
    NSString *strSpeed = nil;
    NSString *strAgle = nil;
    if (m_saveMutableDict) {
        strSpeed = [m_saveMutableDict objectForKey:SWING_SPEED];
        strAgle = [m_saveMutableDict objectForKey:SWING_ANGLE];
    }
    
    //定义视频的大小
    CGSize size ;
#if isPad
    size = CGSizeMake(480,640); // 960*640
#else
    size = CGSizeMake(480,640);
#endif
    
    NSError *error = nil;
    
    NSString *filePath = [[Utilities getSanBoxPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",self.m_strUUID]];
    
    unlink([filePath UTF8String]);
    
    //—-initialize compression engine
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:filePath]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error = %@", [error localizedDescription]);
        
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                       [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                       [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
        AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        
        NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
        
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                         assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        NSParameterAssert(writerInput);
        NSParameterAssert([videoWriter canAddInput:writerInput]);
        
        if ([videoWriter canAddInput:writerInput])
            NSLog(@"  ");
            else
                NSLog(@"  ");
                
                [videoWriter addInput:writerInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
    int __block frame = 0;
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while ([writerInput isReadyForMoreMediaData])
        {
            if(++frame >= [m_mutableArrayDatas count])
            {
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                [videoWriter release];
                dispatch_release(dispatchQueue);
                [NSThread detachNewThreadSelector:@selector(saveOneImageAndPlist) toTarget:self withObject:nil];
                break;
            }
            CVPixelBufferRef buffer = NULL;
            
            int idx = frame;
            UIImage *imageOld = [m_mutableArrayDatas objectAtIndex:idx];
            // 给外部传递百分比
            if (m_delegate && [m_delegate respondsToSelector:@selector(saveVideoWithProgress:)]) {
                [m_delegate saveVideoWithProgress:(1.0f*frame/[m_mutableArrayDatas count])];
            }
            // 图片 cpmvert buffer
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[imageOld CGImage] size:size andSpeed:strSpeed andAngle:strAgle];
            if (buffer)
            {
                //                RECORD_VIDEO_FPS
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, m_floatFPS)]) {
                    dispatch_release(dispatchQueue);
                    [self restoreDefault];
                    // 出错的情况吓会执行这些。
                    // 此处应该恢复刚进来的状况
                    NSLog(@"视频录制出错了");
                }else
                    CFRelease(buffer);
            }
        }
    }];
}


- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size andSpeed:(NSString *)v_speed andAngle:(NSString*)v_angle
{
    //Impact Speed : = %f , Club Angle
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    CGContextSaveGState(context);
    
    // 旋转
    CGContextRotateCTM(context, -M_PI_2);
    CGContextTranslateCTM(context, -size.height, 0);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),CGImageGetHeight(image)), image);
    CGContextRestoreGState(context);
    // 添加logo
    UIImage *imageLogo = [UIImage imageNamed:@"Watermark.png"];
    CGRect rectLogo ;
    //  1280 720
#if isPad
    rectLogo = CGRectMake(size.width-imageLogo.size.width-20.0f, size.height-imageLogo.size.height-170.0f, imageLogo.size.width, imageLogo.size.height);
#else
    rectLogo = CGRectMake(size.width-imageLogo.size.width-50.0f, size.height-imageLogo.size.height-25.0f, imageLogo.size.width, imageLogo.size.height);
#endif
    CGContextDrawImage(context, rectLogo, imageLogo.CGImage);
    // 球杆挥动的时候才显示数据
    if (m_saveMutableDict) {
#if isPad
        MyDrawText(context , CGPointMake(20.0f, size.height-imageLogo.size.height-150.0f),v_speed);
        MyDrawText(context , CGPointMake(20.0f, size.height-imageLogo.size.height-180.0f),v_angle);
#else
        MyDrawText(context , CGPointMake(70.0f, size.height-30.0f),v_speed);
        MyDrawText(context , CGPointMake(70.0f, size.height-53.0f),v_angle);
#endif
    }
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

void MyDrawText (CGContextRef myContext, CGPoint point, NSString *v_strContext) {
#if isPad
    CGContextSelectFont (myContext,
                         "Impact",
                         20.0f,
                         kCGEncodingMacRoman);
#else
    CGContextSelectFont (myContext,
                         "Impact",
                         20.0f,
                         kCGEncodingMacRoman);
#endif
    //    CGContextTranslateCTM(myContext, 0, 768);
    //    CGContextScaleCTM(myContext, 1, -1);
    CGContextSetCharacterSpacing (myContext, 1);
    CGContextSetTextDrawingMode (myContext, kCGTextFillStroke);
    CGContextSetLineWidth(myContext, 1.0f);
    CGContextSetFillColorWithColor(myContext, [UIColor colorWithRed:251.0f/255.0f green:237.0f/255.0f blue:75.0f/255.0f alpha:1.0f].CGColor);
    CGContextSetStrokeColorWithColor(myContext, [UIColor blackColor].CGColor) ;
    CGContextShowTextAtPoint (myContext, point.x, point.y, v_strContext.UTF8String, strlen(v_strContext.UTF8String)); // 10
    //    [v_strContext drawAtPoint:CGPointMake(100  , 100) withFont:[UIFont fontWithName:@"Helvetica" size:20]];
}

**/