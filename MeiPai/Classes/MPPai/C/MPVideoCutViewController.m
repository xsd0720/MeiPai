//
//  MPVideoCutViewController.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/8.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPVideoCutViewController.h"

@interface MPVideoCutViewController ()

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) NSURL *videoFileURL;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) AVPlayerItem *playerItem;


@end

@implementation MPVideoCutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configNav];
    
    [self configAVPlayer];
    
//    self.view.backgroundColor = [UIColor colorWithRed:16 / 255.0f green:16 / 255.0f blue:16 / 255.0f alpha:1.0f];
//    
//    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [_backButton setImage:[UIImage imageNamed:@"vedio_nav_btn_back_nor.png"] forState:UIControlStateNormal];
//    [_backButton setImage:[UIImage imageNamed:@"vedio_nav_btn_back_pre.png"] forState:UIControlStateHighlighted];
//    [_backButton addTarget:self action:@selector(pressBackButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.backButton];
//    
//    [self initPlayLayer];
//    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


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
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"btn_bar_next_a"] forState:UIControlStateNormal];
    [nextButton setImage:[UIImage imageNamed:@"btn_bar_next_b"] forState:UIControlStateHighlighted];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton setTitleColor:RGB(141, 141, 142) forState:UIControlStateHighlighted];
    nextButton.frame = CGRectMake(SCREEN_WIDTH-80, 0, 80, 44);
    nextButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    nextButton.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
    nextButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [nextButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
}


- (void)backButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)configAVPlayer
{
//    if (![NSString getVideoMergeFilePathString]) {
//        NSLog(@"not video can play");
//        
//        return;
//    }
    
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:MergeDictionaryPath error:nil];
    NSArray *files2 = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:ClipsDictionaryPath error:nil];
    NSString *filPath = [files lastObject];

    
    
    [self generateListOfImage];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:self.palyUrl options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_WIDTH);
    _playerLayer.backgroundColor = [[UIColor cyanColor] CGColor];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:_playerLayer];
    
    self.playButton = [[UIButton alloc] initWithFrame:_playerLayer.frame];
    [_playButton setImage:[UIImage imageNamed:@"btn_play_bg_a"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
    
}

-(void)generateListOfImage{
    
    //Create image Image Generator
    AVAsset *asset = [AVAsset assetWithURL:self.palyUrl];
    
    //Create AVVideoComposition
    AVVideoComposition *videoComposition = [AVVideoComposition videoCompositionWithPropertiesOfAsset:asset];
    
    //Retrive video's properties
    NSTimeInterval duration         = CMTimeGetSeconds(asset.duration);
    NSTimeInterval frameDuration    = CMTimeGetSeconds(videoComposition.frameDuration);
    CGSize renderSize = videoComposition.renderSize;
    CGFloat totalFrames = round(duration/frameDuration);
    
    //Create an array to store all time values at which the images captured from the video
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:totalFrames];
    NSLog(@"Total Number of frames %d", (int)totalFrames);
    for (int i = 0; i < totalFrames/6; i++) {
        
        NSValue *time = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(i*frameDuration, videoComposition.frameDuration.timescale)];
        [times addObject:time];
    }
    
    // Launching the process...
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.maximumSize = renderSize;
    imageGenerator.appliesPreferredTrackTransform=TRUE;
    
    __block unsigned int i = 0;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        i++;
        
        CGImageRetain(im);
        if(result == AVAssetImageGeneratorSucceeded){
            
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                
                
                UIImage *image = [UIImage imageWithCGImage:im];

                NSLog(@"========");
//            
//    
//                
//                if(![UIImagePNGRepresentation(image) writeToFile:videoOutputPath options:NSDataWritingFileProtectionNone error:&error]){
//                    NSLog(@"Failed to save image at path %@", videoOutputPath);
//                    i--;
//                }
//                else
////                    [self.savedImageArray addObject:[NSString stringWithFormat:@"VideoFrames%i.png", i]];
//                CGImageRelease(im);
            }];
//            [self.imageWritingQueue addOperation:operation];
            
        }else if (result == AVAssetImageGeneratorFailed){
            NSLog(@"Failed:     Image %d is failed to generate", i);
            NSLog(@"Error: %@", [error localizedDescription]);
        }else if (result == AVAssetImageGeneratorCancelled){
            NSLog(@"Cancelled:  Image %d is cancelled to generate", i);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    };
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
}


- (void)pressPlayButton:(UIButton *)button
{
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
    _playButton.alpha = 0.0f;
}

- (void)pressBackButton:(UIButton *)button
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
