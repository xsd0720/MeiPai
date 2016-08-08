//
//  MPRecordVideoProgressBar.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/5.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPRecordVideoProgressBar.h"

@interface MPRecordVideoProgressBar()

@property (nonatomic, strong)  UIView *shortsView;

//闪烁光标
@property (nonatomic, strong) UIImageView *flashingCursor;

//录制最短分割线
@property (nonatomic, strong) UIView *minRecordIntervalLine;

//录制光标闪烁动画
@property (nonatomic, strong) CABasicAnimation *animationTwinkle;

@end

@implementation MPRecordVideoProgressBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initalize];
    }
    return self;
}

//闪烁动画
- (CABasicAnimation *)animationTwinkle
{
    if (!_animationTwinkle) {
        _animationTwinkle = [CABasicAnimation animationWithKeyPath:@"opacity"];
        _animationTwinkle.duration = 1; // 动画持续时间
        _animationTwinkle.repeatCount = 100; // 重复次数
//        _animationTwinkle.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        _animationTwinkle.fromValue = [NSNumber numberWithFloat:1.0];
        _animationTwinkle.toValue = [NSNumber numberWithFloat:0];
        _animationTwinkle.autoreverses = YES; // 动画结束时执行逆动画
    }
    return _animationTwinkle;
}



- (void)initalize
{

    self.backgroundColor = RGBCOLOR(43, 42, 55);

   //最短分割线
    _minRecordIntervalLine= [[UIView alloc] initWithFrame:CGRectMake(32*3, 0, 2, CGRectGetMaxY(self.bounds))];
    _minRecordIntervalLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:_minRecordIntervalLine];
    
    //装载每小段视频对应的view
    _shortsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds))];
    _shortsView.backgroundColor = self.backgroundColor;
    [self addSubview:_shortsView];

    
    _flashingCursor = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, 2, CGRectGetMaxY(self.bounds)+4)];
    _flashingCursor.image = [UIImage imageNamed:@"record_progressbar_front"];
    [self addSubview:_flashingCursor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startFlashCursorAnimation];
    });
}


- (void)startFlashCursorAnimation
{
    _flashingCursor.hidden = NO;
    [_flashingCursor.layer addAnimation:self.animationTwinkle forKey:@"animationTwinkle"];
}

- (void)stopFlashCursorAnimation
{
     [_flashingCursor.layer removeAllAnimations];
}


//视频开始录制了，停止录制闪烁
- (void)startRecordingAVideo
{
    //停止闪烁
    [self stopFlashCursorAnimation];
    
    //添加一段进度条
    UIView *willAddView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetMaxY(self.bounds))];
    willAddView.backgroundColor = PINKCOLOR;
    if (_shortsView.subviews.count > 0) {
        UIView *lastView = [_shortsView.subviews lastObject];
        willAddView.originX = CGRectGetMaxX(lastView.frame)+1;
    }
    [_shortsView addSubview:willAddView];
    
}

//更新进度条宽度
- (void)updateLastProgressWidth:(CGFloat)width
{
    UIView *lastProgressView = [_shortsView.subviews lastObject];
    if (!lastProgressView) {
        return;
    }
    lastProgressView.width = width;
    [self refreshIndicatorPosition];
   
}


//视频停止录制了
- (void)stopRecordingAVideo
{
    [self startFlashCursorAnimation];
}


- (void)setLastProgressToStyle:(MPRecordVideoProgressBarStyle)style
{
    UIView *lastProgressView = [_shortsView.subviews lastObject];
    if (!lastProgressView) {
        return;
    }
    
    switch (style) {
        case MPRecordVideoProgressBarStyleDelete:
        {
            lastProgressView.backgroundColor = [UIColor redColor];
            [self stopFlashCursorAnimation];
            _flashingCursor.hidden = YES;
        }
            break;
        case MPRecordVideoProgressBarStyleNormal:
        {
            lastProgressView.backgroundColor = PINKCOLOR;
            [self startFlashCursorAnimation];
            _flashingCursor.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)deleteLastProgress
{
    UIView *lastProgressView = [_shortsView.subviews lastObject];
    if (!lastProgressView) {
        return;
    }
    
    [lastProgressView removeFromSuperview];
    
    [self refreshIndicatorPosition];
}


//刷新光标位置
- (void)refreshIndicatorPosition
{
    UIView *lastProgressView = [_shortsView.subviews lastObject];
    if (!lastProgressView) {
        _flashingCursor.originX = 0;
    }else
    {
        //更新闪烁指针位置
        _flashingCursor.originX = CGRectGetMaxX(lastProgressView.frame)+1;
    }
   
}


- (BOOL)hasSubProgress
{
    return _shortsView.subviews.count > 0;
}

@end
