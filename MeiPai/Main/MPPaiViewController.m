//
//  MPPaiViewController.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/4.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPPaiViewController.h"
#import "GPUImage.h"
#import "MPCameraManager.h"

@interface MPPaiViewController ()
{
    GPUImageStillCamera *videoCamera;
}
//    滤镜数组
@property (nonatomic , strong) NSArray *filters;
//@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *meiButton;
@property (nonatomic, strong) UIButton *fanButton;

@property (nonatomic, strong) MPCameraManager *cameraManager ;

@end

@implementation MPPaiViewController
#pragma mark 摄像头管理器

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNav];
    
    [self configCamera];
    
    [self configOtherUI];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)configNav
{
    self.view.backgroundColor = RGBCOLOR(25, 24, 36);
    
    //关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"btn_camera_cancel_a"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(0, 0, 44, 44);
    [closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    
    //闪光灯
    
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashButton setImage:[UIImage imageNamed:@"btn_flash_close_a"] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@"btn_flash_open_a"] forState:UIControlStateSelected];
    _flashButton.frame = CGRectMake(SCREEN_WIDTH-44*3, 0, 44, 44);
    [_flashButton addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];
    
    //美颜磨皮
    _meiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_meiButton setImage:[UIImage imageNamed:@"mei_a"] forState:UIControlStateNormal];
    [_meiButton setImage:[UIImage imageNamed:@"mei_b"] forState:UIControlStateSelected];
    _meiButton.frame = CGRectMake(SCREEN_WIDTH-44*2, 0, 44, 44);
    [_meiButton addTarget:self action:@selector(meiButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_meiButton];
    
    
    //相机tiao
    _fanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fanButton setImage:[UIImage imageNamed:@"btn_flip_a"] forState:UIControlStateNormal];
    _fanButton.frame = CGRectMake(SCREEN_WIDTH-44, 0, 44, 44);
    [_fanButton addTarget:self action:@selector(fanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fanButton];
}

- (void)configCamera
{
    self.cameraManager = [[MPCameraManager alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_WIDTH) superview:self.view];
    [self.cameraManager setFocusImageName:@"camera_focus_bg"];
    [self.cameraManager startCamera];
}

- (void)configOtherUI
{
//    icon_photo_library_a
    
    UIButton *photoMovieButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoMovieButton.frame = CGRectMake(20, SCREEN_HEIGHT-60-60, 60, 60);
    [photoMovieButton setImage:[UIImage imageNamed:@"icon_choose_photo_a"] forState:UIControlStateNormal];
    [photoMovieButton setImage:[UIImage imageNamed:@"icon_choose_photo_b"] forState:UIControlStateHighlighted];
    [photoMovieButton setTitleEdgeInsets:UIEdgeInsetsMake(60, -50, 0, 0)];
    photoMovieButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [photoMovieButton setTitle:@"照片电影" forState:UIControlStateNormal];
    [photoMovieButton setTitleColor:PINKCOLOR forState:UIControlStateHighlighted];
    [self.view addSubview:photoMovieButton];

    UIButton *importMovieButton = [UIButton buttonWithType:UIButtonTypeCustom];
    importMovieButton.frame = CGRectMake(SCREEN_WIDTH-60-20, photoMovieButton.originY, 60, 60);
    [importMovieButton setImage:[UIImage imageNamed:@"icon_photo_library_a"] forState:UIControlStateNormal];
    [importMovieButton setImage:[UIImage imageNamed:@"icon_photo_library_b"] forState:UIControlStateHighlighted];
    [importMovieButton setTitleEdgeInsets:UIEdgeInsetsMake(60, -50, 0, 0)];
    [importMovieButton setTitle:@"导入视频" forState:UIControlStateNormal];
    importMovieButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [importMovieButton setTitleColor:PINKCOLOR forState:UIControlStateHighlighted];
    [self.view addSubview:importMovieButton];
    
    UIButton *beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beginButton.frame = CGRectMake((SCREEN_WIDTH-80)/2, SCREEN_HEIGHT-44-80, 80, 80);
    [beginButton setImage:[UIImage imageNamed:@"begin"] forState:UIControlStateNormal];
    [beginButton addTarget:self action:@selector(beginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beginButton];

}

- (void)closeButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)flashButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    
    [self.cameraManager rotateFlashLight:button.selected];

}


- (void)meiButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    [self.cameraManager rotateMeiYan:button.selected];
}


- (void)fanButtonClick:(UIButton *)button;
{
    [self.cameraManager rotateCamera];
    _meiButton.hidden = self.cameraManager.isFrontCamera;
}

- (void)beginButtonClick
{
    [self.cameraManager snapshotSuccess:^(UIImage *image) {
         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    } snapshotFailure:^{
        
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
