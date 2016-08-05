//
//  LMCameraManager.h
//  Test1030
//
//  Created by xx11dragon on 15/10/30.
//  Copyright © 2015年 xx11dragon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COUNT_DUR_TIMER_INTERVAL 0.05
#define MAX_VIDEO_DUR       10

@class MPCameraManager;
@protocol MPCameraManagerRecorderDelegate <NSObject>

@optional
//recorder开始录制一段视频时
- (void)videoRecorder:(MPCameraManager *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL;

//recorder完成一段视频的录制时
- (void)videoRecorder:(MPCameraManager *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error;

//recorder正在录制的过程中
- (void)videoRecorder:(MPCameraManager *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur;

//recorder删除了某一段视频
- (void)videoRecorder:(MPCameraManager *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error;

//recorder完成视频的合成
- (void)videoRecorder:(MPCameraManager *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL ;

@end

@interface MPCameraManager : NSObject


@property (nonatomic, assign) BOOL isFrontCamera;

@property (nonatomic, assign)  AVCaptureTorchMode torchMode;

@property (nonatomic, assign) id <MPCameraManagerRecorderDelegate> delegate;


//初始化
- (id)initWithFrame:(CGRect)frame superview:(UIView *)superview;

//开启摄像机
- (void)startCamera;

//停止摄像机
- (void)stopCamera;

//设置对焦图片
- (void)setFocusImageName:(NSString *)focusImageName;

//拍照
- (void)snapshotSuccess:(void(^)(UIImage *image))success
        snapshotFailure:(void (^)(void))failure;

//是否美颜
- (void)rotateMeiYan:(BOOL)isMeiYan;

//是否打开闪光灯
- (void)rotateFlashLight:(BOOL)isFlashLight;

//前后摄像头来回切换
- (void)rotateCamera;

//开始录像
- (void)startRecord:(NSString *)savePath;

//停止录像
- (void)stopRecord;


@end
