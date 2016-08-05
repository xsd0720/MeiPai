//
//  NSTimer+CycleScrollView.h
//  CycleScrollView
//
//  Created by lin wu on 6/25/15.
//  Copyright (c) 2015 lin wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (CycleScrollView)
- (void)pauseTimer;                                             //暂停时间
- (void)resumeTimer;                                            //回复时间
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;
@end
