//
//  LMCameraManager.h
//  Test1030
//
//  Created by xx11dragon on 15/10/30.
//  Copyright © 2015年 xx11dragon. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MPCameraManager : NSObject


@property (nonatomic, assign) BOOL isFrontCamera;

@property (nonatomic, assign)  AVCaptureTorchMode torchMode;

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


@end
