//
//  MPVideoCutViewController.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/8.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPVideoCutViewController.h"
#import "MPVideoProcessing.h"
#import "MPVideFramePreViewCell.h"
#import "MPVideoClipControl.h"
#define FramePreviewItemSize   40

#define FRAMEPREVIEWCELLIDENTITIFER @"FRAMEPREVIEWCELLIDENTITIFER"

@interface MPVideoCutViewController ()

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) NSURL *videoFileURL;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) UIScrollView *playerLayerScroll;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (assign, nonatomic) CGSize videoSize;


@property (strong, nonatomic) UIButton *promptButton;

@property (strong, nonatomic) MPVideoClipControl *videoClipControl;

@property (strong, nonatomic) NSMutableArray *framePreviewsArray;


//视频比例切换
@property (strong, nonatomic) UIButton *biliButton;

@end

@implementation MPVideoCutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configNav];
    
    [self configAVPlayer];
    
    //加载帧预览
    [self configAboutFramePreview];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
#pragma mark --
#pragma mark -- config Nav -------

- (void)configNav
{
    self.view.backgroundColor = RGBCOLOR(25, 24, 36);
    
    //关闭按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"btn_bar_back_a"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"btn_bar_back_b"] forState:UIControlStateHighlighted];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:RGB(141, 141, 142) forState:UIControlStateHighlighted];
    backButton.frame = CGRectMake(0, 0, 80, 44);
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    backButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 100, 44)];
    titleLabel.centerX = CGRectGetMaxX(self.view.bounds)/2;
    titleLabel.text = @"裁剪";
    titleLabel.textAlignment = 1;
    titleLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:titleLabel];
    
    
    //下一步
    UIButton *overButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overButton setImage:[UIImage imageNamed:@"btn_save_draft_c"] forState:UIControlStateNormal];
    [overButton setImage:[UIImage imageNamed:@"btn_save_draft_c"] forState:UIControlStateHighlighted];
    [overButton setTitle:@"完成" forState:UIControlStateNormal];
    [overButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [overButton setTitleColor:RGB(141, 141, 142) forState:UIControlStateHighlighted];
    overButton.frame = CGRectMake(SCREEN_WIDTH-80, 0, 80, 44);
//    overButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    overButton.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
    overButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [overButton addTarget:self action:@selector(overButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:overButton];
}

- (void)backButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)overButtonClick
{
    NSLog(@"完成");
}


#pragma mark --
#pragma mark -- config AVPlayer -------

- (void)setVideoSize:(CGSize)videoSize
{
    CGFloat p = videoSize.width/videoSize.height;
    if (videoSize.width > videoSize.height) {
        CGFloat nH = self.playerLayerScroll.frame.size.height;
        CGFloat nW = p * nH;
        _videoSize = CGSizeMake(nW, nH);
    }
    else if(videoSize.height > videoSize.width)
    {
        CGFloat nW = self.playerLayerScroll.frame.size.width;
        CGFloat nH = nW/p;
        _videoSize = CGSizeMake(nW, nH);
    }
    else
    {
        _videoSize = self.playerLayer.bounds.size;
    }
}

- (void)configAVPlayer
{
    if (!self.editVideoURL) {
        NSLog(@"editVideoURL is empty");
        return;
    }
    

    _playerLayerScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_WIDTH)];
    _playerLayerScroll.bounces = NO;
    _playerLayerScroll.showsVerticalScrollIndicator = NO;
    _playerLayerScroll.showsHorizontalScrollIndicator = NO;
    _playerLayerScroll.scrollEnabled = NO;
    [self.view addSubview:_playerLayerScroll];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:self.editVideoURL options:nil];
    
    AVAssetTrack *assetTrack = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    self.videoSize = assetTrack.naturalSize;
    
    _playerLayerScroll.contentSize = self.videoSize;
//    [_playerLayerScroll setContentOffset:CGPointMake((self.videoSize.width-SCREEN_WIDTH)/2, 0)];
    
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
    _playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerLayer.masksToBounds = YES;
    [_playerLayerScroll.layer addSublayer:_playerLayer];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, 40, 40)];
    [_playButton setImage:[UIImage imageNamed:@"btn_play_bg_a"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
}
- (void)pressPlayButton:(UIButton *)button
{
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
    _playButton.alpha = 0.0f;
}


#pragma mark --
#pragma mark -- config AboutFramePreview -------


- (void)configAboutFramePreview
{
    
    _promptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_promptButton setImage:[UIImage imageNamed:@"icon_guide_arrow"] forState:UIControlStateNormal];
    [_promptButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
    [_promptButton setTitle:@"拖动选择你要裁剪的片段" forState:UIControlStateNormal];
    _promptButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    _promptButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _promptButton.frame = CGRectMake(0, CGRectGetMaxY(self.playerLayerScroll.frame) + 25, SCREEN_WIDTH, 15);
    [self.view addSubview:_promptButton];
    
    
    
    _videoClipControl = [[MPVideoClipControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_promptButton.frame)+15, SCREEN_WIDTH, 70)];
    [_videoClipControl addTarget:self action:@selector(videoClipCoverViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_videoClipControl];
    
    
    [[MPVideoProcessing shareInstance] framePreviewsFromVideoURL:self.editVideoURL parseImagesArray:self.videoClipControl.framePreviewsArray completionHandle:^(NSArray *fpImages) {
       dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoClipControl.framePreviewsCollectionView reloadData];
       });
      
    } failureHandle:^(NSError *error) {
        NSLog(@"%@", [error description]);
    }];
    
    
    //视频比例转化
    _biliButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_biliButton setTitle:@"1:1" forState:UIControlStateNormal];
    _biliButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    [_biliButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [_biliButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _biliButton.frame = CGRectMake(SCREEN_WIDTH-30-25, CGRectGetMaxY(_videoClipControl.frame)+15, 25, 25);
    _biliButton.layer.cornerRadius = 6;
    _biliButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _biliButton.layer.borderWidth = 2;
    [_biliButton addTarget:self action:@selector(biliButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_biliButton];
}




- (void)videoClipCoverViewValueChanged:(MPVideoClipControl *)videoClipCover
{
    [self.player pause];
    
    float seekTime = videoClipCover.value*CMTimeGetSeconds(self.player.currentItem.duration);
    CMTime cmTime = CMTimeMakeWithSeconds(seekTime, self.player.currentItem.duration.timescale);
    [self.player seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

}

- (void)biliButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    NSLog(@"%@", NSStringFromCGRect(self.playerLayer.videoRect));
    
    if (sender.selected) {
        
         self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _playerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH+(self.videoSize.width-SCREEN_WIDTH), SCREEN_WIDTH);
            [_playerLayerScroll setContentOffset:CGPointMake((self.videoSize.width-SCREEN_WIDTH)/2, 0) animated:NO];
            
            _playerLayerScroll.scrollEnabled = YES;
        });
        
//        [UIView animateWithDuration:5 animations:^{
//            
//            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//        } completion:^(BOOL finished) {
//            
//           
//        }];

        
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
   
        
    }else
    {
        
        _playerLayerScroll.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.1 animations:^{
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//            [_playerLayerScroll setContentOffset:CGPointMake((self.videoSize.width-SCREEN_WIDTH)/2, 0)];
            _playerLayer.frame = CGRectMake((self.videoSize.width-SCREEN_WIDTH)/2, 0, SCREEN_WIDTH, SCREEN_WIDTH);
        }];
    }
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - PlayEndNotification
- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification
{
    if ((AVPlayerItem *)notification.object != _playerItem) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        _playButton.alpha = 1.0f;
    }];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
