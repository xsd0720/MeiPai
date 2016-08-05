////
////  ProcessBar.m
////  SBVideoCaptureDemo
////
////
//
//// 版权属于原作者
//// http://code4app.com (cn) http://code4app.net (en)
//// 发布代码于最专业的源码分享网站: Code4App.com
//
//#import "ProgressBar.h"
//#import "SBCaptureToolKit.h"
//#import "SBCaptureToolKit.h"
//
//#define BAR_H 18
//#define BAR_MARGIN 2
//
//#define BAR_MIN_W 80
//
//#define BG_COLOR color(11, 11, 11, 1)
//
//#define INDICATOR_W 16
//#define INDICATOR_H 22
//
//#define TIMER_INTERVAL 1.0f
//
//@interface ProgressBar ()
//
//@property (strong, nonatomic) NSMutableArray *progressViewArray;
//
//@property (strong, nonatomic) UIView *barView;
//@property (strong, nonatomic) UIImageView *progressIndicator;
//
//@property (strong, nonatomic) NSTimer *shiningTimer;
//
//@end
//
//@implementation ProgressBar
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self initalize];
//    }
//    return self;
//}
//
//- (void)initalize
//{
//    self.autoresizingMask = UIViewAutoresizingNone;
//    self.backgroundColor = RGBCOLOR(11, 11, 11);
//    self.progressViewArray = [[NSMutableArray alloc] init];
//    
//    //barView
//    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_MARGIN, self.frame.size.width, BAR_H)];
//    _barView.backgroundColor = RGBCOLOR(38, 38, 38);
//    [self addSubview:_barView];
//    
//    //最短分割线
//    UIView *intervalView = [[UIView alloc] initWithFrame:CGRectMake(BAR_MIN_W, 0, 1, BAR_H)];
//    intervalView.backgroundColor = [UIColor blackColor];
//    [_barView addSubview:intervalView];
//    
//    //indicator
//    self.progressIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_W, INDICATOR_H)];
//    _progressIndicator.backgroundColor = [UIColor clearColor];
//    _progressIndicator.image = [UIImage imageNamed:@"record_progressbar_front.png"];
//    _progressIndicator.center = CGPointMake(0, self.frame.size.height / 2);
//    [self addSubview:_progressIndicator];
//}
//
//- (UIView *)getProgressView
//{
//    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, BAR_H)];
//    progressView.backgroundColor = RGBCOLOR(68, 214, 254);
//    progressView.autoresizesSubviews = YES;
//    
//    return progressView;
//}
//
//- (void)refreshIndicatorPosition
//{
//    UIView *lastProgressView = [_progressViewArray lastObject];
//    if (!lastProgressView) {
//        _progressIndicator.center = CGPointMake(0, self.frame.size.height / 2);
//        return;
//    }
//    
//    _progressIndicator.center = CGPointMake(MIN(lastProgressView.frame.origin.x + lastProgressView.frame.size.width, self.frame.size.width - _progressIndicator.frame.size.width / 2 + 2), self.frame.size.height / 2);
//}
//
//- (void)onTimer:(NSTimer *)timer
//{
//    [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
//        _progressIndicator.alpha = 0;
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
//            _progressIndicator.alpha = 1;
//        }];
//    }];
//}
//
//#pragma mark - method
//- (void)startShining
//{
//    self.shiningTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
//}
//
//- (void)stopShining
//{
//    [_shiningTimer invalidate];
//    self.shiningTimer = nil;
//    _progressIndicator.alpha = 1;
//}
//
//- (void)addProgressView
//{
//    UIView *lastProgressView = [_progressViewArray lastObject];
//    CGFloat newProgressX = 0.0f;
//    
//    if (lastProgressView) {
//        CGRect frame = lastProgressView.frame;
//        frame.size.width -= 1;
//        lastProgressView.frame = frame;
//        
//        newProgressX = frame.origin.x + frame.size.width + 1;
//    }
//    
//    UIView *newProgressView = [self getProgressView];
////    [SBCaptureToolKit setView:newProgressView toOriginX:newProgressX];
//    
//    [_barView addSubview:newProgressView];
//    
//    [_progressViewArray addObject:newProgressView];
//}
//
//- (void)setLastProgressToWidth:(CGFloat)width
//{
//    UIView *lastProgressView = [_progressViewArray lastObject];
//    if (!lastProgressView) {
//        return;
//    }
//    
////    [SBCaptureToolKit setView:lastProgressView toSizeWidth:width];
//    [self refreshIndicatorPosition];
//}
//
//- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style
//{
//    UIView *lastProgressView = [_progressViewArray lastObject];
//    if (!lastProgressView) {
//        return;
//    }
//    
//    switch (style) {
//        case ProgressBarProgressStyleDelete:
//        {
//            lastProgressView.backgroundColor = BAR_RED_COLOR;
//            _progressIndicator.hidden = YES;
//        }
//            break;
//        case ProgressBarProgressStyleNormal:
//        {
//            lastProgressView.backgroundColor = BAR_BLUE_COLOR;
//            _progressIndicator.hidden = NO;
//        }
//            break;
//        default:
//            break;
//    }
//}
//
//- (void)deleteLastProgress
//{
//    UIView *lastProgressView = [_progressViewArray lastObject];
//    if (!lastProgressView) {
//        return;
//    }
//    
//    [lastProgressView removeFromSuperview];
//    [_progressViewArray removeLastObject];
//    
//    _progressIndicator.hidden = NO;
//    
//    [self refreshIndicatorPosition];
//}
//
//+ (ProgressBar *)getInstance
//{
//    ProgressBar *progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, BAR_H + BAR_MARGIN * 2)];
//    return progressBar;
//}
//
//@end
//
//
