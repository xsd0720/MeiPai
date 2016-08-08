//
//  MPRecordVideoProgressBar.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/5.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MPRecordVideoProgressBarStyleNormal,
    MPRecordVideoProgressBarStyleDelete,
} MPRecordVideoProgressBarStyle;

@interface MPRecordVideoProgressBar : UIView

@property (nonatomic, assign) BOOL hasSubProgress;

- (void)startRecordingAVideo;

- (void)updateLastProgressWidth:(CGFloat)width;

- (void)setLastProgressToStyle:(MPRecordVideoProgressBarStyle)style;

- (void)stopRecordingAVideo;

- (void)deleteLastProgress;

- (void)startFlashCursorAnimation;

- (void)stopFlashCursorAnimation;

@end
