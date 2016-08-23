//
//  CameaHelp.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/23.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#undef PRODUCER_HAS_VIDEO_CAPTURE
#define PRODUCER_HAS_VIDEO_CAPTURE (__IPHONE_OS_VERSION_MIN_REQUIRED >= 40000 && TARGET_OS_EMBEDDED)
@protocol CameraHelpDelegate
-(void) getSampleBufferImage:(UIImage *) v_image ;
@end

@interface CameraHelp : NSObject
#if PRODUCER_HAS_VIDEO_CAPTURE
<AVCaptureVideoDataOutputSampleBufferDelegate>
#endif
{
@private
    int mWidth;
    int mHeight;
    int mFps;
    BOOL mFrontCamera;
    BOOL mFirstFrame;
    BOOL mStarted;
    UIView* mPreview;
    id<CameraHelpDelegate> outDelegate;
#if PRODUCER_HAS_VIDEO_CAPTURE
    AVCaptureSession* mCaptureSession;
    AVCaptureDevice *mCaptureDevice;
#endif
}
//单例模式
+ (CameraHelp*)shareCameraHelp;
+ (void)closeCamera;
//设置前置摄像头
- (BOOL)setFrontCamera;
//设置后置摄像头
- (BOOL)setBackCamera;
//开始前设置捕获参数
- (void)prepareVideoCapture:(int) width andHeight: (int)height andFps: (int) fps andFrontCamera:(BOOL) bfront andPreview:(UIView*) view;
//开始捕获
- (void)startVideoCapture;
//停止捕获
- (void)stopVideoCapture;
//设置要显示到得View
- (void)setPreview: (UIView*)preview;
//设置数据输出
- (void)setVideoDataOutputBuffer:(id<CameraHelpDelegate>)delegate;
@end
