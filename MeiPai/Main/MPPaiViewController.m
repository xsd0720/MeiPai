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
#import "MPRecordVideoProgressBar.h"
#import "MPVideoCutViewController.h"
#import "DeleteButton.h"
#import "MPPaiChooseMusicViewController.h"
#import "MPVideoProcessing.h"

#define MinRecordDuration     3.0

@interface MPPaiViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPCameraManagerRecorderDelegate, UIViewControllerTransitioningDelegate, UIAlertViewDelegate>
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

@property (nonatomic, strong) MPCameraManager *cameraManager;

@property (nonatomic, strong) MPRecordVideoProgressBar *mpRecordVideoProgressBar;

//选择音乐
@property (nonatomic, strong) UIButton *chooseMusicButton;
//照片电影
@property (nonatomic, strong) UIButton *photoMovieButton;
//导入视频
@property (nonatomic, strong) UIButton *importMovieButton;
//删除最后一个录制的视频
@property (nonatomic, strong) DeleteButton *delLastRecordMovieButton;
//确定
@property (nonatomic, strong) UIButton *rightButton;
//开始录制按钮
@property (nonatomic, strong) UIButton *beginButton;

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
    self.cameraManager.delegate = self;
    [self.cameraManager setFocusImageName:@"camera_focus_bg"];
//    [self.cameraManager startCamera];
    
    

    _chooseMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chooseMusicButton setImage:[UIImage imageNamed:@"icon_choose_music_a"] forState:UIControlStateNormal];
    _chooseMusicButton.frame = CGRectMake(0, 0, 30, 30);
    _chooseMusicButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    _chooseMusicButton.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor];
    _chooseMusicButton.layer.cornerRadius = 15;
    _chooseMusicButton.layer.borderWidth = 1;
    _chooseMusicButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_chooseMusicButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
    _chooseMusicButton.frame = CGRectMake(SCREEN_WIDTH-35, SCREEN_WIDTH, 30, 30);
    [_chooseMusicButton addTarget:self action:@selector(chooseMusicButtonClic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_chooseMusicButton];
 
    
}


- (UIButton *)photoMovieButton
{
    if (!_photoMovieButton) {
        _photoMovieButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoMovieButton.frame = CGRectMake(20, SCREEN_HEIGHT-60-60, 60, 60);
        [_photoMovieButton setImage:[UIImage imageNamed:@"icon_choose_photo_a"] forState:UIControlStateNormal];
        [_photoMovieButton setImage:[UIImage imageNamed:@"icon_choose_photo_b"] forState:UIControlStateHighlighted];
        [_photoMovieButton setTitleEdgeInsets:UIEdgeInsetsMake(60, -50, 0, 0)];
        _photoMovieButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_photoMovieButton setTitle:@"照片电影" forState:UIControlStateNormal];
        [_photoMovieButton setTitleColor:PINKCOLOR forState:UIControlStateHighlighted];
        [_photoMovieButton addTarget:self action:@selector(photoMovieButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_photoMovieButton];
    }
    return _photoMovieButton;
}

- (UIButton *)importMovieButton
{
    if (!_importMovieButton) {
        _importMovieButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _importMovieButton.frame = CGRectMake(SCREEN_WIDTH-60-20, SCREEN_HEIGHT-60-60, 60, 60);
        [_importMovieButton setImage:[UIImage imageNamed:@"icon_photo_library_a"] forState:UIControlStateNormal];
        [_importMovieButton setImage:[UIImage imageNamed:@"icon_photo_library_b"] forState:UIControlStateHighlighted];
        [_importMovieButton setTitleEdgeInsets:UIEdgeInsetsMake(60, -50, 0, 0)];
        [_importMovieButton setTitle:@"导入视频" forState:UIControlStateNormal];
        _importMovieButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_importMovieButton setTitleColor:PINKCOLOR forState:UIControlStateHighlighted];
        [_importMovieButton addTarget:self action:@selector(importMoiveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _importMovieButton;
    
}

- (UIButton *)beginButton
{
    if (!_beginButton) {
        _beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _beginButton.frame = CGRectMake((SCREEN_WIDTH-80)/2, SCREEN_HEIGHT-44-80, 80, 80);
        [_beginButton setImage:[UIImage imageNamed:@"begin"] forState:UIControlStateNormal];
        [_beginButton addTarget:self action:@selector(beginButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_beginButton addTarget:self action:@selector(beginButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [_beginButton addTarget:self action:@selector(beginButtonTouchUpInside) forControlEvents:UIControlEventTouchUpOutside];
        [_beginButton setExclusiveTouch:YES];
    }
    return _beginButton;
}

- (DeleteButton *)delLastRecordMovieButton
{
    if (!_delLastRecordMovieButton) {
        _delLastRecordMovieButton = [DeleteButton buttonWithType:UIButtonTypeCustom];
        _delLastRecordMovieButton.frame = CGRectMake(20, SCREEN_HEIGHT-60-60, 60, 60);
        [_delLastRecordMovieButton setExclusiveTouch:YES];
        _delLastRecordMovieButton.hidden = YES;
        [_delLastRecordMovieButton addTarget:self action:@selector(delLastRecordMovieButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _delLastRecordMovieButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(SCREEN_WIDTH-60-20, SCREEN_HEIGHT-60-60, 60, 60);
        [_rightButton setImage:[UIImage imageNamed:@"btn_camera_done_c"] forState:UIControlStateNormal];
        [_rightButton setExclusiveTouch:YES];
        [_rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.hidden = YES;
    }
    return _rightButton;
}

- (void)configOtherUI
{
    
    [self.view addSubview:self.delLastRecordMovieButton];
    [self.view addSubview:self.photoMovieButton];
    
    [self.view addSubview:self.beginButton];
    
    [self.view addSubview:self.rightButton];
    [self.view addSubview:self.importMovieButton];
    
    
    self.mpRecordVideoProgressBar = [[MPRecordVideoProgressBar alloc] initWithFrame:CGRectMake(0, 44+SCREEN_WIDTH, SCREEN_WIDTH, 7)];
    [self.view addSubview:self.mpRecordVideoProgressBar];
    

}

- (void)closeButtonClick
{
    if ([self.cameraManager getVideoCount] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定放弃这段视频吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.cameraManager stopCamera];
        
        [self.cameraManager clearAllClips];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//选择音乐
- (void)chooseMusicButtonClic
{
    MPPaiChooseMusicViewController *paiChooseMusicVC = [[MPPaiChooseMusicViewController alloc] init];
    paiChooseMusicVC.chooseMusicBlock = ^(NSString *fileName){
        if ([fileName isEqualToString:@"无音乐"]) {
            [self.chooseMusicButton setTitle:@"" forState:UIControlStateNormal];
            self.chooseMusicButton.width = 30;
            self.chooseMusicButton.originX = SCREEN_WIDTH-self.chooseMusicButton.width-10;
            self.cameraManager.musicFilePath = nil;
        }else
        {
    
            CGSize s = MB_TEXTSIZE(fileName, self.chooseMusicButton.titleLabel.font);
            
            self.chooseMusicButton.width = s.width+30;
            self.chooseMusicButton.originX = SCREEN_WIDTH-self.chooseMusicButton.width-10;
            [self.chooseMusicButton setTitle:fileName forState:UIControlStateNormal];
            
             NSString *musicFilePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:fileName];
            self.cameraManager.musicFilePath = musicFilePath;
        }
        
    };
    [self presentViewController:paiChooseMusicVC animated:YES completion:nil];
}


- (void)flashButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    
    self.cameraManager.isFlashLight = button.selected;

}

- (void)meiButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    self.cameraManager.isMeiYan = button.selected;
}


- (void)fanButtonClick:(UIButton *)button
{
    [self.cameraManager rotateCamera];

    _flashButton.hidden = self.cameraManager.isFrontCamera;

}


#pragma mark --
#pragma mark ----------  other button event

- (void)delLastRecordMovieButtonClick:(DeleteButton *)button
{
    if (button.style == DeleteButtonStyleNormal) {//第一次按下删除按钮
        [_mpRecordVideoProgressBar setLastProgressToStyle:MPRecordVideoProgressBarStyleDelete];
        [button setButtonStyle:DeleteButtonStyleDelete];
    } else if (button.style == DeleteButtonStyleDelete) {//第二次按下删除按钮
        [self.cameraManager deleteLastVideo];
        [_mpRecordVideoProgressBar deleteLastProgress];
        
        if ([self.cameraManager getVideoCount] > 0) {
            [button setButtonStyle:DeleteButtonStyleNormal];
        } else {
            [button setButtonStyle:DeleteButtonStyleDisable];
        }
    }

}


- (void)rightButtonClick
{
    [self.cameraManager mergeVideoFiles];
}

- (void)beginButtonClick
{
    [self.cameraManager snapshotSuccess:^(UIImage *image) {
         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    } snapshotFailure:^{
        
    }];
}

- (void)beginButtonTouchDown
{
    NSLog(@"开始录");
    [self.delLastRecordMovieButton setButtonStyle:DeleteButtonStyleDisable];
    [self.mpRecordVideoProgressBar setLastProgressToStyle:MPRecordVideoProgressBarStyleNormal];
    
    [self.cameraManager startRecord:[NSString getVideoSaveFilePathString]];
}

- (void)beginButtonTouchUpInside
{
    NSLog(@"停止录");
    
    [self.cameraManager stopRecord];
}

- (void)importMoiveButtonClick
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // Only movie
        NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        picker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    }
    
    [self presentViewController:picker animated:YES completion:nil];

}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 1.
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"info = %@",info);
    
    // 2.
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        
        if (url && ![url isFileURL])
        {
            NSLog(@"Input file from camera is invalid.");
            return;
        }
        
        if ([[MPVideoProcessing shareInstance] getVideoDuration:url] < MinRecordDuration) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:@"视频时长必须大于3秒"
                                                           delegate:nil
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles: nil];
            [alert show];
            return;
        }

        MPVideoCutViewController *videoCutVC = [[MPVideoCutViewController alloc] init];
        videoCutVC.editVideoURL = url;
        [self presentViewController:videoCutVC animated:YES completion:nil];
    }
    else
    {
        NSLog(@"Error media type");
        return;
    }
}



- (void)photoMovieButtonClick
{
    MPVideoCutViewController *videoCutVC = [[MPVideoCutViewController alloc] init];
    //    videoCutVC.palyUrl = outputFileURL;
    [self presentViewController:videoCutVC animated:YES completion:nil];
}


#pragma mark - MPCameraManagerRecorderDelegate
- (void)videoRecorder:(MPCameraManager *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL
{
    NSLog(@"正在录制视频: %@", fileURL);
    [self.mpRecordVideoProgressBar startRecordingAVideo];
    
    self.photoMovieButton.hidden = YES;
    self.delLastRecordMovieButton.hidden = NO;
    
    self.rightButton.hidden = NO;
    self.importMovieButton.hidden = YES;

}

- (void)videoRecorder:(MPCameraManager *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error
{
    
    if (error) {
        NSLog(@"录制视频错误:%@", error);
    } else {
        NSLog(@"录制视频完成: %@", outputFileURL);
    }
    
    if (totalDur >= MAX_VIDEO_DUR) {
        [self rightButtonClick];
    }
    
    [self.delLastRecordMovieButton setButtonStyle:DeleteButtonStyleNormal];
    
    [_mpRecordVideoProgressBar stopRecordingAVideo];

}

- (void)videoRecorder:(MPCameraManager *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error
{
    if (error) {
        NSLog(@"删除视频错误: %@", error);
    } else {
        NSLog(@"删除了视频: %@", fileURL);
        NSLog(@"现在视频长度: %f", totalDur);
    }

    if ([self.cameraManager getVideoCount] > 0) {
        [_delLastRecordMovieButton setStyle:DeleteButtonStyleNormal];
    } else {
        self.photoMovieButton.hidden = NO;
        self.delLastRecordMovieButton.hidden = YES;
        
        self.rightButton.hidden = YES;
        self.importMovieButton.hidden = NO;
    }
    [self.mpRecordVideoProgressBar startFlashCursorAnimation];
    
}

- (void)videoRecorder:(MPCameraManager *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur
{
    
    //    NSLog(@"%f", videoDuration);
        [_mpRecordVideoProgressBar updateLastProgressWidth:videoDuration / MAX_VIDEO_DUR * _mpRecordVideoProgressBar.frame.size.width];
    //
    //    _okButton.enabled = (videoDuration + totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(MPCameraManager *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL
{
    MPVideoCutViewController *videoCutVC = [[MPVideoCutViewController alloc] init];
    videoCutVC.editVideoURL = outputFileURL;
    [self presentViewController:videoCutVC animated:YES completion:nil];
}

//
//-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
//{
//    
//    return uinav;
//}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
