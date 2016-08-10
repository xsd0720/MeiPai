//
//  MPVideoProcessing.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/8.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^CompletionHandler)(NSURL *mergeFileURL);

@interface MPVideoProcessing : NSObject

@property (nonatomic) CompletionHandler completionHandler;

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


- (void)mergeAndExportVideos:(NSArray*)videosPathArray completionHandler:(CompletionHandler)completionHandler;

+(MPVideoProcessing *)shareInstance;
@property (retain, nonatomic) AVAssetExportSession *exportSession;

@end
