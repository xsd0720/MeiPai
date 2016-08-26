//
//  HJImagesToVideo.m
//  HJImagesToVideo
//
//  Created by Harrison Jackson on 8/4/13.
//  Copyright (c) 2013 Harrison Jackson. All rights reserved.
//  1.mp4.cdncomtdl

#import "HJImagesToVideo.h"

CGSize const DefaultFrameSize                             = (CGSize){480, 320};

NSInteger const DefaultFrameRate                          = 1;
NSInteger const TransitionFrameCount                      = 20;
NSInteger const FramesToWaitBeforeTransition              = 20;

BOOL const DefaultTransitionShouldAnimate = YES;

@implementation HJImagesToVideo

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo videoFromImages:images
                              toPath:path
                            withSize:DefaultFrameSize
                             withFPS:DefaultFrameRate
                  animateTransitions:DefaultTransitionShouldAnimate
                   withCallbackBlock:callbackBlock];
}

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo videoFromImages:images
                              toPath:path
                            withSize:DefaultFrameSize
                             withFPS:DefaultFrameRate
                  animateTransitions:animate
                   withCallbackBlock:callbackBlock];
}

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
                withFPS:(int)fps
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo videoFromImages:images
                              toPath:path
                            withSize:DefaultFrameSize
                             withFPS:fps
                  animateTransitions:animate
                   withCallbackBlock:callbackBlock];
}

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
               withSize:(CGSize)size
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo videoFromImages:images
                              toPath:path
                            withSize:size
                             withFPS:DefaultFrameRate
                  animateTransitions:animate
                   withCallbackBlock:callbackBlock];
}

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
               withSize:(CGSize)size
                withFPS:(int)fps
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo writeImageAsMovie:images
                                toPath:path
                                  size:size
                                   fps:fps
                    animateTransitions:animate
                     withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo saveVideoToPhotosWithImages:images
                                        withSize:DefaultFrameSize
                              animateTransitions:DefaultTransitionShouldAnimate
                               withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo saveVideoToPhotosWithImages:images
                                        withSize:DefaultFrameSize
                              animateTransitions:animate
                               withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                           withSize:(CGSize)size
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo saveVideoToPhotosWithImages:images
                                        withSize:size
                                         withFPS:DefaultFrameRate
                              animateTransitions:animate
                               withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                            withFPS:(int)fps
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    [HJImagesToVideo saveVideoToPhotosWithImages:images
                                        withSize:DefaultFrameSize
                                         withFPS:fps
                              animateTransitions:animate
                               withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                           withSize:(CGSize)size
                            withFPS:(int)fps
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"temp.mp4"]];
    [[NSFileManager defaultManager] removeItemAtPath:[NSString getPhotoMovieMergeFilePathString] error:NULL];
    
    [HJImagesToVideo videoFromImages:images
                              toPath:[NSString getPhotoMovieMergeFilePathString]
                            withSize:size
                             withFPS:fps
                  animateTransitions:animate
                   withCallbackBlock:^(BOOL success) {
                       
                       if (success) {
//                           UISaveVideoAtPathToSavedPhotosAlbum(tempPath, self, nil, nil);
                       }
                       
                       if (callbackBlock) {
                           callbackBlock(success);
                       }
                   }];
}

+ (void)writeImageAsMovie:(NSArray *)array
                   toPath:(NSString*)path
                     size:(CGSize)size
                      fps:(int)fps
       animateTransitions:(BOOL)shouldAnimateTransitions
        withCallbackBlock:(SuccessBlock)callbackBlock
{
    NSLog(@"%@", path);
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    if (error) {
        if (callbackBlock) {
            callbackBlock(NO);
        }
        return;
    }
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: [NSNumber numberWithInt:size.width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:size.height]};
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer;
    CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &buffer);
    
    CMTime presentTime = CMTimeMake(0, fps);
    
    int i = 0;
    while (1)
    {
        
		if(writerInput.readyForMoreMediaData){
            
			presentTime = CMTimeMake(i, fps);
            
			if (i >= [array count]) {
				buffer = NULL;
			} else {
                UIImage *im = array[i];
				buffer = [HJImagesToVideo pixelBufferFromCGImage:[im CGImage] size:CGSizeMake(im.size.width, im.size.height)];
			}
			
			if (buffer) {
                //append buffer
                
                BOOL appendSuccess = [HJImagesToVideo appendToAdapter:adaptor
                                                          pixelBuffer:buffer
                                                               atTime:presentTime
                                                            withInput:writerInput];

                
                NSAssert(appendSuccess, @"Failed to append");
                
                if (i + 1 < array.count) {

                    //Create time each fade frame is displayed
                    CMTime fadeTime = CMTimeMake(1, fps*TransitionFrameCount);
            
                    //Add a delay, causing the base image to have more show time before fade begins.
                    for (int b = 0; b < FramesToWaitBeforeTransition; b++) {
                        presentTime = CMTimeAdd(presentTime, fadeTime);
                    }
       
//                    presentTime = CMTimeMake(i, fps);
                    
//                    for (int b = 0; b < FramesToWaitBeforeTransition; b++) {
//                        presentTime = CMTimeAdd(presentTime, fadeTime);
//                    }
//
                    
                    //Adjust fadeFrameCount so that the number and curve of the fade frames and their alpha stay consistant
                    NSInteger framesToFadeCount = TransitionFrameCount - FramesToWaitBeforeTransition;
                    
                    //Apply fade frames
                    for (double j = 1; j < framesToFadeCount; j++) {
                         UIImage *im = array[i];
                        buffer = [HJImagesToVideo crossFadeImage:[array[i] CGImage]
                                                         toImage:[array[i + 1] CGImage]
                                                          atSize:CGSizeMake(im.size.width, im.size.height)
                                                       withAlpha:j/framesToFadeCount];
                        
                        BOOL appendSuccess = [HJImagesToVideo appendToAdapter:adaptor
                                                                  pixelBuffer:buffer
                                                                       atTime:presentTime
                                                                    withInput:writerInput];
                        presentTime = CMTimeAdd(presentTime, fadeTime);
                        
                        NSAssert(appendSuccess, @"Failed to append");
                    }
                    
                    
                    
                    
                }
                
                i++;
			} else {
				
				//Finish the session:
				[writerInput markAsFinished];
                
				[videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"Successfully closed video writer");
                    if (videoWriter.status == AVAssetWriterStatusCompleted) {
                        if (callbackBlock) {
                            callbackBlock(YES);
                        }
                    } else {
                        if (callbackBlock) {
                            callbackBlock(NO);
                        }
                    }
                }];
				
				CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
				
				NSLog (@"Done");
                break;
            }
        }
    }
}

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
                                      size:(CGSize)imageSize
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0 + (imageSize.width-CGImageGetWidth(image))/2,
                                           (imageSize.height-CGImageGetHeight(image))/2,
                                           CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (CVPixelBufferRef)crossFadeImage:(CGImageRef)baseImage
                           toImage:(CGImageRef)fadeInImage
                            atSize:(CGSize)imageSize
                         withAlpha:(CGFloat)alpha
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGRect drawRect = CGRectMake(0 + (imageSize.width-CGImageGetWidth(baseImage))/2,
                                 (imageSize.height-CGImageGetHeight(baseImage))/2,
                                 CGImageGetWidth(baseImage),
                                 CGImageGetHeight(baseImage));
    
//    CGContextDrawImage(context, CGRectMake(-25, -25, drawRect.size.width+50, drawRect.size.height+50), baseImage);
    
    CGContextBeginTransparencyLayer(context, nil);
    CGContextSetAlpha( context, alpha );
    CGContextDrawImage(context, drawRect, fadeInImage);
    CGContextEndTransparencyLayer(context);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (BOOL)appendToAdapter:(AVAssetWriterInputPixelBufferAdaptor*)adaptor
            pixelBuffer:(CVPixelBufferRef)buffer
                 atTime:(CMTime)presentTime
              withInput:(AVAssetWriterInput*)writerInput
{
    while (!writerInput.readyForMoreMediaData) {
        usleep(1);
    }
    
    return [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
}

//- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size andSpeed:(NSString *)v_speed andAngle:(NSString*)v_angle
//{
//    //Impact Speed : = %f , Club Angle
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
//    CVPixelBufferRef pxbuffer = NULL;
//    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, &pxbuffer);
//    
//    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
//    
//    CVPixelBufferLockBaseAddress(pxbuffer, 0);
//    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
//    NSParameterAssert(pxdata != NULL);
//    
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
//    NSParameterAssert(context);
//    CGContextSaveGState(context);
//    
//    // 旋转
//    CGContextRotateCTM(context, -M_PI_2);
//    CGContextTranslateCTM(context, -size.height, 0);
//    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),CGImageGetHeight(image)), image);
//    CGContextRestoreGState(context);
//    // 添加logo
//    UIImage *imageLogo = [UIImage imageNamed:@"Watermark.png"];
//    CGRect rectLogo ;
//    //  1280 720
//#if isPad
//    rectLogo = CGRectMake(size.width-imageLogo.size.width-20.0f, size.height-imageLogo.size.height-170.0f, imageLogo.size.width, imageLogo.size.height);
//#else
//    rectLogo = CGRectMake(size.width-imageLogo.size.width-50.0f, size.height-imageLogo.size.height-25.0f, imageLogo.size.width, imageLogo.size.height);
//#endif
//    CGContextDrawImage(context, rectLogo, imageLogo.CGImage);
//    // 球杆挥动的时候才显示数据
//    if (m_saveMutableDict) {
//#if isPad
//        MyDrawText(context , CGPointMake(20.0f, size.height-imageLogo.size.height-150.0f),v_speed);
//        MyDrawText(context , CGPointMake(20.0f, size.height-imageLogo.size.height-180.0f),v_angle);
//#else
//        MyDrawText(context , CGPointMake(70.0f, size.height-30.0f),v_speed);
//        MyDrawText(context , CGPointMake(70.0f, size.height-53.0f),v_angle);
//#endif
//    }
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    
//    return pxbuffer;
//}
//
//void MyDrawText (CGContextRef myContext, CGPoint point, NSString *v_strContext) {
//#if isPad
//    CGContextSelectFont (myContext,
//                         "Impact",
//                         20.0f,
//                         kCGEncodingMacRoman);
//#else
//    CGContextSelectFont (myContext,
//                         "Impact",
//                         20.0f,
//                         kCGEncodingMacRoman);
//#endif
//    //    CGContextTranslateCTM(myContext, 0, 768);
//    //    CGContextScaleCTM(myContext, 1, -1);
//    CGContextSetCharacterSpacing (myContext, 1);
//    CGContextSetTextDrawingMode (myContext, kCGTextFillStroke);
//    CGContextSetLineWidth(myContext, 1.0f);
//    CGContextSetFillColorWithColor(myContext, [UIColor colorWithRed:251.0f/255.0f green:237.0f/255.0f blue:75.0f/255.0f alpha:1.0f].CGColor);
//    CGContextSetStrokeColorWithColor(myContext, [UIColor blackColor].CGColor) ;
//    CGContextShowTextAtPoint (myContext, point.x, point.y, v_strContext.UTF8String, strlen(v_strContext.UTF8String)); // 10
//    //    [v_strContext drawAtPoint:CGPointMake(100  , 100) withFont:[UIFont fontWithName:@"Helvetica" size:20]];
//}


@end
