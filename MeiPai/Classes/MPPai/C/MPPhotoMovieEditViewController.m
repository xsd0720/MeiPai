//
//  MPPhotoMovieEditViewController.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/22.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPPhotoMovieEditViewController.h"

#import "MPEditVideoSwitch.h"
#import "MPEditVideoCell.h"
#import "GPUImage.h"
#import "MPVideoProcessing.h"
#define EditVideItemSize CGSizeMake(65, 80)
#define EDITVIDEOCELLIDENTIFIER @"EDITVIDEOCELLIDENTIFIER"


@interface MPPhotoMovieEditViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    BOOL movieRunning;
}
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) NSURL *videoFileURL;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) UIScrollView *playerLayerScroll;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (nonatomic, strong) GPUImageMovie *movieFile;
@property (nonatomic, strong) GPUImageView  *videoView;


@property (nonatomic, strong) MPEditVideoSwitch *editVideoSwitch;

@property (nonatomic, strong) UIButton *musicChooseButton;
@property (nonatomic, strong) UIButton *orginSoundButton;

@property (nonatomic, strong) UICollectionView *editVideoCollectionView;

@property (nonatomic, strong) NSArray *longEffects;
@property (nonatomic, strong) NSArray *mvStyles;

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *currentFilter;

@end

@implementation MPPhotoMovieEditViewController

- (NSArray *)longEffects
{
    return @[
             @{
                 @"imageName" : @"LongEffects4",
                 @"title" : @"晨光"
                 
                 },
             @{
                 @"imageName" : @"LongEffects8",
                 @"title" : @"流年"
                 },
             @{
                 
                 @"imageName" : @"LongEffects9",
                 @"title" : @"沙漏"
                 },
             @{
                 @"imageName" : @"LongEffects10",
                 @"title" : @"Seine"
                 },
             @{
                 
                 @"imageName" : @"LongEffects11",
                 @"title" : @"绿岛"
                 }
             
             ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNav];
    
    [self setupVideo];
    
    [self configOtherUI];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
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
    
    [_player seekToTime:kCMTimeZero];
    [_player play];
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
    [nextButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
}

- (void)backButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextButtonClick
{
    
    [_movieFile cancelProcessing];
    _player = nil;
    //    [_player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        [[MPVideoProcessing shareInstance] exportVideoURLWithFilter:self.currentFilter inputVideoURL:self.editVideoURL];
    });
    
}


#pragma mark --
#pragma mark -- config avplayer

//- (void)configAVPlayer
//{
//    if (!self.editVideoURL) {
//        NSLog(@"editVideoURL is empty");
//        return;
//    }
//
//
//
//
//    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:self.editVideoURL options:nil];
//
//    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
//    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//    _playerLayer.frame = CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_WIDTH);
//    _playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
//    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    _playerLayer.backgroundColor = [[UIColor cyanColor] CGColor];
//    [self.view.layer addSublayer:_playerLayer];
//
//    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, 40, 40)];
//    [_playButton setImage:[UIImage imageNamed:@"btn_play_bg_a"] forState:UIControlStateNormal];
//    [_playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_playButton];
//
//}
- (void)setupVideo
{
    
    _playerItem = [[AVPlayerItem alloc]initWithURL:self.editVideoURL];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];

    _playerLayer = [[AVPlayerLayer alloc] init];
    _playerLayer.frame = CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_WIDTH);
    
    [_playerLayer setPlayer:_player];
    [self.view.layer addSublayer:_playerLayer];
    
    
    //
//    _movieFile = [[GPUImageMovie alloc] initWithPlayerItem:_playerItem];
//    
//    //    _movieFile.runBenchmark = YES;
//    _movieFile.playAtActualSpeed = YES;
//    [self.view sendSubviewToBack:self.videoView];
//    
//    
//    self.videoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_WIDTH)];
//    [self.view addSubview:self.videoView];
//    
//    [_movieFile addTarget:self.videoView];
//    [_movieFile startProcessing];
    [_player play];
    
    
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-44, 40, 40)];
    self.playButton.backgroundColor = [UIColor redColor];
    [_playButton setImage:[UIImage imageNamed:@"btn_play_bg_a"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
}

- (void)pressPlayButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_player play];
    }else
    {
        [_player pause];
    }
    
}

#pragma mark --
#pragma mark ---------config Other UI


/**
 *  加载 collectionView 视图
 */
- (UICollectionView *)editVideoCollectionView{
    if (!_editVideoCollectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(EditVideItemSize.width, EditVideItemSize.height);
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        
        _editVideoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, EditVideItemSize.height) collectionViewLayout:layout];
        [self.view addSubview:_editVideoCollectionView];
        //        _editVideoCollectionView.alwaysBounceVertical = YES;
        _editVideoCollectionView.showsHorizontalScrollIndicator = NO;
        _editVideoCollectionView.showsVerticalScrollIndicator = NO;
        _editVideoCollectionView.showsVerticalScrollIndicator = NO;
        _editVideoCollectionView.backgroundColor = [UIColor clearColor];
        
        _editVideoCollectionView.delegate = self;
        _editVideoCollectionView.dataSource = self;
        
        
        //  注册重用池
        [_editVideoCollectionView registerClass:[MPEditVideoCell class] forCellWithReuseIdentifier:EDITVIDEOCELLIDENTIFIER];
        [_editVideoCollectionView setExclusiveTouch:YES];
        
    }
    return _editVideoCollectionView;
}

- (void)configOtherUI
{
    //滤镜 MV switch
    _editVideoSwitch = [[MPEditVideoSwitch alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH+44+25, 100, 35)];
    [self.view addSubview:_editVideoSwitch];
    
    
    _musicChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _musicChooseButton.frame = CGRectMake(SCREEN_WIDTH-80, _editVideoSwitch.originY, 40, 40);
    [_musicChooseButton setImage:[UIImage imageNamed:@"btn_close_music_b"] forState:UIControlStateNormal];
    [_musicChooseButton setImage:[UIImage imageNamed:@"btn_music_a"] forState:UIControlStateSelected];
    [_musicChooseButton addTarget:self action:@selector(musicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_musicChooseButton];
    
    
    _orginSoundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _orginSoundButton.frame = CGRectMake(SCREEN_WIDTH-40, _editVideoSwitch.originY, 40, 40);
    [_orginSoundButton setImage:[UIImage imageNamed:@"btn_sound_b"] forState:UIControlStateNormal];
    [_orginSoundButton setImage:[UIImage imageNamed:@"btn_close_sound_a"] forState:UIControlStateSelected];
    [_orginSoundButton addTarget:self action:@selector(originButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_orginSoundButton];
    
    
    self.editVideoCollectionView.originY = CGRectGetMaxY(_editVideoSwitch.frame)+20;
    [self.editVideoCollectionView reloadData];
    
    
    
}

- (void)originButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
}

- (void)musicButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.longEffects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPEditVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EDITVIDEOCELLIDENTIFIER forIndexPath:indexPath];
    cell.datasource = self.longEffects[indexPath.row];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentFilter = nil;
    
    switch (indexPath.row) {
        case 0:
        {
            GPUImageBrightnessFilter *fi = [[GPUImageBrightnessFilter alloc] init];
            fi.brightness = 0.1;
            self.currentFilter = fi;
        }
            break;
        case 1:
        {
            self.currentFilter = [[GPUImageEmbossFilter alloc] init];
        }
            break;
        case 2:
        {
            self.currentFilter = [[GPUImageGrayscaleFilter alloc] init];
        }
            break;
        case 3:
        {
            self.currentFilter = [[GPUImageGammaFilter alloc] init];
        }
            break;
        case 4:
        {
            
        }
            break;
        default:
            break;
    }
    
    if (self.currentFilter) {
        [_movieFile removeAllTargets];
        [_movieFile addTarget:self.currentFilter];
        [self.currentFilter addTarget:self.videoView];
    }
    
    
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
