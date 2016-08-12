//
//  MPVideoProcessing.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/8.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^MergeCompletionHandler)(NSURL *mergeFileURL);
typedef void(^FramePreviewsParseFinished)(NSArray *fpImages);
typedef void(^FailureHandle)(NSError *error);

@interface MPVideoProcessing : NSObject

@property (retain, nonatomic) AVAssetExportSession *exportSession;

@property (nonatomic) MergeCompletionHandler mergeCompletionHandler;

@property (nonatomic) FramePreviewsParseFinished framePreviewsParseFinished;

+(MPVideoProcessing *)shareInstance;


//获取视频时长
- (CGFloat)getVideoDuration:(NSURL*)URL;


////必须是fileURL
////截取将会是视频的中间部分
////这里假设拍摄出来的视频总是高大于宽的
//
///*!
// @method mergeAndExportVideosAtFileURLs:
// 
// @param fileURLArray
// 包含所有视频分段的文件URL数组，必须是[NSURL fileURLWithString:...]得到的
// 
// @discussion
// 将所有分段视频合成为一段完整视频，并且裁剪为正方形
// */
//+ (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray;


- (void)mergeAndExportVideos:(NSArray*)videosPathArray bgMusicURL:(NSURL *)bgMusicURL isG:(BOOL)isG completionHandler:(MergeCompletionHandler)completionHandler;

//制作照片电影
- (void)makePhotoMovieFromPhotos:(NSArray *)photos;

//解析出视频帧预览图片集合
- (void)framePreviewsFromVideoURL:(NSURL *)videoURL parseImagesArray:(NSMutableArray *)parseImagesArray completionHandle:(FramePreviewsParseFinished)completionHandler failureHandle:(FailureHandle)failureHandle;


@end
