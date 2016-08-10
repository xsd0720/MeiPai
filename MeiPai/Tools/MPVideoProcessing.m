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
@implementation MPVideoProcessing

+(MPVideoProcessing *)shareInstance{
    static MPVideoProcessing *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MPVideoProcessing alloc]init];
    });
    return _instance;
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


- (void)mergeAndExportVideos:(NSArray*)videosPathArray completionHandler:(CompletionHandler)completionHandler{
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
        
//        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //合成录音
        AVAssetTrack *assetAudioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
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
    
    
    

    NSURL *mergeFileURL = [NSURL fileURLWithPath:[NSString getVideoMergeFilePathString]];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = videoComposition;
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







- (CGSize)getVideoSize:(NSURL *)filePathURL
{
    AVAsset *asset = [AVAsset assetWithURL:filePathURL];
    
    if (!asset) {
        return CGSizeZero;
    }

    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    return assetTrack.naturalSize;
}

@end
