//
//  MPRecordVideoProgressBar.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/5.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPRecordVideoProgressBar : UIView

- (void)startRecordingAVideo;

- (void)setLastProgressToWidth:(CGFloat)width;

- (void)stopRecordingAVideo;

@end
