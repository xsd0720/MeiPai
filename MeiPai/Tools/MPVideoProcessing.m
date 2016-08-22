//
//  MPVideoProcessing.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/8.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPVideoProcessing.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MPVideoProcessing()

@property (nonatomic, strong) GPUImageMovie *exportFileImageMovie;

@property (nonatomic, strong) GPUImageMovieWriter *exportImageMovieWriter;

@end

@implementation MPVideoProcessing

+(MPVideoProcessing *)shareInstance{
    static MPVideoProcessing *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MPVideoProcessing alloc]init];
    });
    return _instance;
}
#pragma mark ----
#pragma mark ------------getVideoDuration----------

- (CGFloat)getVideoDuration:(NSURL*)URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    
    return second;
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
    mainCompositionInst.renderSize = renderSize;
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
//                [_delegate videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
//            }
//            if (self.completionHandler) {
//                self.completionHandler();
//            }
        
        });
    }];
}


#pragma mark ----==============================================================================
#pragma mark -- 视频合成，添加BGM

- (void)mergeAndExportVideos:(NSArray*)videosPathArray bgMusicURL:(NSURL *)bgMusicURL isG:(BOOL)isG completionHandler:(MergeCompletionHandler)completionHandler{
    if (videosPathArray.count == 0) {
        return;
    }
    
    //创建新的音频 视频 相当于一个空的视频文件
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //空视频文件添加音频  视频通道
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    //统计当前追加视频到了哪一秒
    CMTime totalDuration = kCMTimeZero;
    
    //循环取出视频URL
    for (int i = 0; i < videosPathArray.count; i++) {
        
        //根据url创建视频资源()
        NSURL *assetURL;
       
        
        if ([videosPathArray[i] isKindOfClass:[NSURL class]]) {
            assetURL = videosPathArray[i];
           
        }
        else if ([videosPathArray[i] isKindOfClass:[NSString class]]){
            assetURL = [NSURL fileURLWithPath:videosPathArray[i]];
        }
        if (!assetURL) {
            return;
        }
        
        
        NSURL *audioAssetURL = [NSURL URLWithString:[[assetURL absoluteString] stringByReplacingOccurrencesOfString:@"mp4" withString:@"caf"]];
        
        AVURLAsset *asset = [AVURLAsset assetWithURL:assetURL];
        AVURLAsset *audioAsset =[[AVURLAsset alloc]initWithURL:audioAssetURL options:nil];
        NSError *erroraudio = nil;
        
        //合成录音
        AVAssetTrack *assetAudioTrack = [[isG?asset:audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];

        
        
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
    }
    
    //视频画面处理
    AVMutableVideoComposition *videoComposition = nil;
    if (TRUE) {
       videoComposition = [self addVideoWaterMaskLayerVideoTrack:videoTrack totalDuration:totalDuration];
    }
    
    //视频声音处理
    AVMutableAudioMix *audioMix = nil;
    if (bgMusicURL) {
        audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = [self addBGMMusicPath:bgMusicURL composition:mixComposition totalDuration:totalDuration];
    }
    

    

    NSURL *mergeFileURL = [NSURL fileURLWithPath:[NSString getVideoMergeFilePathString]];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    if (audioMix) {
       exporter.audioMix = audioMix;
    }
   
    if (videoComposition) {
        exporter.videoComposition = videoComposition;
    }
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        NSLog(@"error = %@", exporter.error);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(mergeFileURL);
        });
    }];
}
#pragma mark --
#pragma mark -- 添加视频水印logo(美拍)
- (AVMutableVideoComposition *)addVideoWaterMaskLayerVideoTrack:(AVMutableCompositionTrack *)videoTrack totalDuration:(CMTime)totalDuration
{
    // 4. Effects
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    [parentLayer addSublayer:videoLayer];
    
    //添加美拍水印
    UIImage *waterLogoImage = [UIImage imageNamed:@"icon_app_logo"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((parentLayer.bounds.size.width-waterLogoImage.size.width)/2, (parentLayer.bounds.size.height-waterLogoImage.size.height)/2, waterLogoImage.size.width, waterLogoImage.size.height)];
    logoImageView.image = waterLogoImage;
    
    
    
    //添加美拍背景
    UIImage *waterbgImage = [UIImage imageNamed:@"Watermark_Large"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:parentLayer.bounds];
    bgImageView.image = waterbgImage;
    
    CALayer *logoBaseLayer = [CALayer layer];
    [logoBaseLayer addSublayer:bgImageView.layer];
    [logoBaseLayer addSublayer:logoImageView.layer];
    logoBaseLayer.opacity = 0;
    
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    rotationAnimation.fromValue = @0.0f;
    rotationAnimation.toValue = @1.0f;
    
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.beginTime = CMTimeGetSeconds(totalDuration)-0.5;
    [logoBaseLayer addAnimation:rotationAnimation forKey:@"movet"];
    
    
    [parentLayer addSublayer:logoBaseLayer];
    
    
    
    // Make a "pass through video track" video composition.
    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    
    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
    
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = [NSArray arrayWithObject:passThroughInstruction];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    videoComposition.renderSize =  videoTrack.naturalSize;
    
    return videoComposition;

}

#pragma 添加背景音乐
- (NSMutableArray *)addBGMMusicPath:(NSURL *)bgMusicURL composition:(AVMutableComposition *)mixComposition totalDuration:(CMTime)totalDuration
{
    //所有需要添加的音频都放这个数组里<格式统一 AVAudioMixInputParameters>
    NSMutableArray<AVAudioMixInputParameters *> *audioMixInputParametersArray = [NSMutableArray array];
    
    //读取背景音乐文件
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:bgMusicURL options:nil];
    AVAssetTrack *songAssetTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    //创建背景音乐音频输入轨道(此时为一个画面轨道，两个音频轨道)
    AVMutableCompositionTrack *songAssetCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //背景音乐写入背景音乐音轨（从第0秒写到视频最后一秒，注意不可是歌曲的最后一秒， 会报错）
    [songAssetCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, totalDuration)
                                       ofTrack:songAssetTrack
                                        atTime:kCMTimeZero
                                         error:nil];
    //创建背景音乐音轨输入参数
    AVMutableAudioMixInputParameters *songAudioInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:songAssetCompositionTrack];
    [songAudioInputParameters setVolume:0.2f atTime:CMTimeMakeWithSeconds(0, 1)];
    
    //添加到数组
    [audioMixInputParametersArray addObject:songAudioInputParameters];

    
    //获取视频本身的声音
    AVMutableCompositionTrack *originalAudioTrack = [[mixComposition tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //创建原始声音的可变音频输入
    AVMutableAudioMixInputParameters *originalAudioInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:originalAudioTrack];
    [originalAudioInputParameters setVolume:1.0f atTime:CMTimeMakeWithSeconds(0, 1)];
    //添加到数组
    [audioMixInputParametersArray addObject:originalAudioInputParameters];
    

    return audioMixInputParametersArray;
}



- (CGSize)getVideoSize:(NSURL *)filePathURL
{
    AVAsset *asset = [AVAsset assetWithURL:filePathURL];
    
    if (!asset) {
        return CGSizeZero;
    }

    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    return assetTrack.naturalSize;
}


#pragma mark ----==============================================================================
#pragma mark -- 制作照片电影

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image  size:(CGSize)imageSize
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
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
    //    CGContextConcatCTM(context, frameTransform);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}




//- (void) writeImages:(NSArray *)imagesArray ToMovieAtPath:(NSString *) path withSize:(CGSize) size
//          inDuration:(float)duration byFPS:(int32_t)fps{
//    //Wire the writer:
//    NSError *error = nil;
//    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
//                                                            fileType:AVFileTypeQuickTimeMovie
//                                                               error:&error];
//    NSParameterAssert(videoWriter);
//    
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   AVVideoCodecH264, AVVideoCodecKey,
//                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
//                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
//                                   nil];
//    
//    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
//                                             assetWriterInputWithMediaType:AVMediaTypeVideo
//                                             outputSettings:videoSettings];
//    
//    
//    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
//                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
//                                                     sourcePixelBufferAttributes:nil];
//    NSParameterAssert(videoWriterInput);
//    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
//    [videoWriter addInput:videoWriterInput];
//    
//    //Start a session:
//    [videoWriter startWriting];
//    [videoWriter startSessionAtSourceTime:kCMTimeZero];
//    
//    //Write some samples:
//    CVPixelBufferRef buffer = NULL;
//    
//    int frameCount = 0;
//    
//    int imagesCount = (int)imagesArray.count;
//    float averageTime = duration/imagesCount;
//    int averageFrame = (int)(averageTime * fps);
//    
//    for(UIImage * img in imagesArray)
//    {
//        buffer = [self pixelBufferFromCGImage:[img CGImage] andSize:size];
//        
//        BOOL append_ok = NO;
//        int j = 0;
//        while (!append_ok && j < 30)
//        {
//            if (adaptor.assetWriterInput.readyForMoreMediaData)
//            {
//                printf("appending %d attemp %d\n", frameCount, j);
//                
//                CMTime frameTime = CMTimeMake(frameCount,(int32_t) fps);
//                float frameSeconds = CMTimeGetSeconds(frameTime);
//                NSLog(@"frameCount:%d,kRecordingFPS:%d,frameSeconds:%f",frameCount,fps,frameSeconds);
//                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
//                
//                if(buffer)
//                    [NSThread sleepForTimeInterval:0.05];
//            }
//            else
//            {
//                printf("adaptor not ready %d, %d\n", frameCount, j);
//                [NSThread sleepForTimeInterval:0.1];
//            }
//            j++;
//        }
//        if (!append_ok) {
//            printf("error appending image %d times %d\n", frameCount, j);
//        }
//        
//        frameCount = frameCount + averageFrame;
//    }
//    
//    //Finish the session:
//    [videoWriterInput markAsFinished];
//    [videoWriter finishWriting];
//    NSLog(@"finishWriting");
//}

- (void)makePhotoMovieFromPhotos:(NSArray *)photos photoSuccess:(PhotoMovieSuccess)success
{
    [[NSFileManager defaultManager] removeItemAtPath:[NSString getPhotoMovieMergeFilePathString] error:nil];
    
    NSError *error = nil;
    CGSize size = CGSizeMake(640, 640);
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:[NSString getPhotoMovieMergeFilePathString]]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    NSParameterAssert(videoWriter);
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
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
    
    
    
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;
    
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        
        
//        [photos en]
        
//        int i = 0;
//        int startTime = 0;
//        while ([writerInput isReadyForMoreMediaData]) {
//            CVPixelBufferRef buffer = NULL;
//            if (i < photos.count) {
//                buffer = [self pixelBufferFromCGImage:[[photos objectAtIndex:i] CGImage] size:CGSizeMake(640, 640)];
//                [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(startTime, 30)];
//                
//                startTime += 3;
//            }
//            else
//            {
//                [writerInput markAsFinished];
//                //If change to fininshWritingWith... Cause Zero bytes file. I'm Trying to fix.
//                [videoWriter finishWritingWithCompletionHandler:^{
//                    success();
//                }];
//            }
//            
//        }
        
    }];
    
    
    
    
//    CVPixelBufferRef buffer = NULL;
//    buffer = [self pixelBufferFromCGImage:[[photos objectAtIndex:0] CGImage] size:CGSizeMake(640, 640)];
//    CVPixelBufferPoolCreatePixelBuffer (NULL, adaptor.pixelBufferPool, &buffer);
//    [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
//    
//    int i = 1;
//    int frameCount = 1;
//    while (1)
//    {
//        if(writerInput.readyForMoreMediaData){
//            CMTime frameTime = CMTimeMake(1, 30);
//            CMTime lastTime=CMTimeMake(i, 30);
//            CMTime presentTime=CMTimeAdd(lastTime, frameTime);
//            if (i >= [photos count])
//            {
//                buffer = NULL;
//            }
//            else
//            {
//                buffer = [self pixelBufferFromCGImage:[[photos objectAtIndex:i] CGImage] size:CGSizeMake(640, 640)];
//            }
//            if (buffer)
//            {
//                // append buffer
//                [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frameCount, 30)];
//                i++;
//                frameCount += 30;
//                
//            }
//            else
//            {
//                //Finish the session:
//                [writerInput markAsFinished];
//                //If change to fininshWritingWith... Cause Zero bytes file. I'm Trying to fix.
//                [videoWriter finishWritingWithCompletionHandler:^{
//                    success();
//                }];
//                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
//                
//              
//                break;
//            }
//        }
//    }

    
//        //Write some samples:
//        CVPixelBufferRef buffer = NULL;
//    
//        int frameCount = 0;
//    
//        int imagesCount = (int)photos.count;
//        float averageTime = 3/imagesCount;
//        int averageFrame = (int)(averageTime * 10);
//    
//        for(UIImage * img in photos)
//        {
//            buffer = [self pixelBufferFromCGImage:[img CGImage] size:CGSizeMake(640, 640)];
//    
//            BOOL append_ok = NO;
//            int j = 0;
//            while (!append_ok && j < 30)
//            {
//                if (adaptor.assetWriterInput.readyForMoreMediaData)
//                {
//                    printf("appending %d attemp %d\n", frameCount, j);
//    
//                    CMTime frameTime = CMTimeMake(frameCount,(int32_t) 10);
//                    float frameSeconds = CMTimeGetSeconds(frameTime);
//                    NSLog(@"frameCount:%d,kRecordingFPS:%d,frameSeconds:%f",frameCount,10,frameSeconds);
//                    append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
//    
//                    if(buffer)
//                        [NSThread sleepForTimeInterval:0.05];
//                }
//                else
//                {
//                    printf("adaptor not ready %d, %d\n", frameCount, j);
//                    [NSThread sleepForTimeInterval:0.1];
//                }
//                j++;
//            }
//            if (!append_ok) {
//                printf("error appending image %d times %d\n", frameCount, j);
//            }
//    
//            frameCount = frameCount + averageFrame;
//        }
//    
//        //Finish the session:
//        [writerInput markAsFinished];
//        [videoWriter finishWritingWithCompletionHandler:^{
//            success();
//        }];
//        NSLog(@"finishWriting");
    
}

#pragma mark ----==============================================================================
#pragma mark -- 获取视频帧预览所需帧
//解析出视频帧预览图片集合
- (void)framePreviewsFromVideoURL:(NSURL *)videoURL parseImagesArray:(NSMutableArray *)parseImagesArray completionHandle:(FramePreviewsParseFinished)completionHandler failureHandle:(FailureHandle)failureHandle
{
    //Create image Image Generator
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    
    //Create AVVideoComposition
    AVVideoComposition *videoComposition = [AVVideoComposition videoCompositionWithPropertiesOfAsset:asset];
    
    //Retrive video's properties
    NSTimeInterval duration         = CMTimeGetSeconds(asset.duration);
    NSTimeInterval frameDuration    = CMTimeGetSeconds(videoComposition.frameDuration);
    CGSize renderSize = videoComposition.renderSize;
    CGFloat totalFrames = round(duration/frameDuration);
    
    //Create an array to store all time values at which the images captured from the video
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:totalFrames];
    NSLog(@"Total Number of frames %d", (int)totalFrames);
    for (int i = 0; i < duration; i++) {
        
        NSValue *time = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(i, videoComposition.frameDuration.timescale)];
        [times addObject:time];
    }
    
    // Launching the process...
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.maximumSize = renderSize;
    imageGenerator.appliesPreferredTrackTransform=TRUE;
    
    __block unsigned int i = 0;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if(result == AVAssetImageGeneratorSucceeded){
            
            UIImage *image = [UIImage imageWithCGImage:im];
            [parseImagesArray addObject:image];
            
            if (parseImagesArray.count == times.count) {
                completionHandler(parseImagesArray);
            }
            
        }else if (result == AVAssetImageGeneratorFailed){
            NSLog(@"Failed:     Image %d is failed to generate", i);
            NSLog(@"Error: %@", [error localizedDescription]);
            failureHandle(error);
        }else if (result == AVAssetImageGeneratorCancelled){
            NSLog(@"Cancelled:  Image %d is cancelled to generate", i);
            NSLog(@"Error: %@", [error localizedDescription]);
            failureHandle(error);
        }
    };
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
}



- (NSURL *)exportVideoURLWithFilter:(GPUImageOutput<GPUImageInput> *)filter inputVideoURL:(NSURL *)inputVideoURL
{
    //创建滤镜处理视频载体(GPUImageMovie)
    _exportFileImageMovie = [[GPUImageMovie alloc] initWithURL:inputVideoURL];
    
    //runBenchmark--控制台打印current frame，就是视频处理到哪一秒了，只是一个控制台输出，YES就输出，NO就不输出
    _exportFileImageMovie.runBenchmark = NO;
    
    //控制GPUImageView预览视频时的速度是否要保持真实的速度。如果设为NO，则会将视频的所有帧无间隔渲染，导致速度非常快。设为YES，则会根据视频本身时长计算出每帧的时间间隔，然后每渲染一帧，就sleep一个时间间隔，从而达到正常的播放速度。
    _exportFileImageMovie.playAtActualSpeed = NO;
    
    //控制视频是否循环播放。当你不想预览，而是想将处理过的结果输出到文件时，步骤也类似，只是不再需要创建GPUImageView，而是需要一个GPUImageMovieWriter：
    
    _exportFileImageMovie.shouldRepeat = NO;
    

    //添加滤镜
    if (filter) {
       [_exportFileImageMovie addTarget:filter];
    }
    
    
    //有了载体就要开始输出了使用 （GPUImageMovieWriter）  outputMovieURL 为最终输出的url
    NSString *pathToTempMov = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempMovie.mov"];
    NSLog(@"%@", pathToTempMov);
    //unlink 是C语言中函数，简单的说就是如果本地存在改路径指定的文件，就会删除重置文件中的内容
    unlink([pathToTempMov UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    
    NSURL *outputTempMovieURL = [NSURL fileURLWithPath:pathToTempMov];
    
    _exportImageMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:outputTempMovieURL size:[self getVideoSize:inputVideoURL]];
    
    //判断是否存在滤镜 filter
    if ((NSNull*)filter != [NSNull null] && filter != nil)
    {
        //滤镜上添加写入者（GPUImageMovieWriter）
        [filter addTarget:_exportImageMovieWriter];
    }
    else
    {
        //视频处理器(GPUImageMovie) 上添加写入者（GPUImageMovieWriter）
        [_exportFileImageMovie addTarget:_exportImageMovieWriter];
        
    }
    //是否允许视频声音通过
    _exportImageMovieWriter.shouldPassthroughAudio = YES;
    //如果允许视频声音通过，设置声音源
    _exportFileImageMovie.audioEncodingTarget = _exportImageMovieWriter;
    //保存所有的视频帧和音频样本
    
    [_exportFileImageMovie enableSynchronizedEncodingUsingMovieWriter:_exportImageMovieWriter];
    
    //写入者开始录制
    [_exportImageMovieWriter startRecording];
    //视频载体开始处理(可以理解为开始播放，就是写入者开始录制，视频载体本身开始播放，这样就把每一帧都拍下来了)
    
    [_exportFileImageMovie startProcessing];
    
    
    __weak MPVideoProcessing *ws = self;
    [ws.exportImageMovieWriter setCompletionBlock:^{
        //
        if ((NSNull*)filter != [NSNull null] && filter != nil)
        {
            //移除写入者从滤镜中
            [filter removeTarget:_exportImageMovieWriter];
        }
        else
        {
            //移除写入者从视频载体中(主要是为了节省资源吧)
            [_exportFileImageMovie removeTarget:_exportImageMovieWriter];
        }
        
        //录制完毕要关闭录制动作
        [ws.exportImageMovieWriter finishRecordingWithCompletionHandler:^{
//            录制完成，最终视频保存在outputMovieURL，进一步处理就可以了
            NSLog(@"chenggong ");
            [self save:outputTempMovieURL];
            
        }];
    }];


    [_exportImageMovieWriter setFailureBlock:^(NSError *error) {
        NSLog(@"%@", [error description]);
        
    }];
    return nil;
}


- (void)save:(NSURL *)url{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:url
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Save video fail:%@",error);
                                    } else {
                                        NSLog(@"Save video succeed.");
                                    }
                                }];
}

@end
