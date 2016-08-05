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
@interface MPPaiViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPCameraManagerRecorderDelegate>
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
    [photoMovieButton addTarget:self action:@selector(photoMovieButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoMovieButton];

    UIButton *importMovieButton = [UIButton buttonWithType:UIButtonTypeCustom];
    importMovieButton.frame = CGRectMake(SCREEN_WIDTH-60-20, photoMovieButton.originY, 60, 60);
    [importMovieButton setImage:[UIImage imageNamed:@"icon_photo_library_a"] forState:UIControlStateNormal];
    [importMovieButton setImage:[UIImage imageNamed:@"icon_photo_library_b"] forState:UIControlStateHighlighted];
    [importMovieButton setTitleEdgeInsets:UIEdgeInsetsMake(60, -50, 0, 0)];
    [importMovieButton setTitle:@"导入视频" forState:UIControlStateNormal];
    importMovieButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [importMovieButton setTitleColor:PINKCOLOR forState:UIControlStateHighlighted];
    [importMovieButton addTarget:self action:@selector(importMoiveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:importMovieButton];
    
    UIButton *beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beginButton.frame = CGRectMake((SCREEN_WIDTH-80)/2, SCREEN_HEIGHT-44-80, 80, 80);
    [beginButton setImage:[UIImage imageNamed:@"begin"] forState:UIControlStateNormal];
//    [beginButton addTarget:self action:@selector(beginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [beginButton addTarget:self action:@selector(beginButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [beginButton addTarget:self action:@selector(beginButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [beginButton addTarget:self action:@selector(beginButtonTouchUpInside) forControlEvents:UIControlEventTouchUpOutside];

    [self.view addSubview:beginButton];
    
    
//    self.progressBar = [ProgressBar getInstance];
//    [SBCaptureToolKit setView:_progressBar toOriginY:DEVICE_SIZE.width];
//    [self.view insertSubview:_progressBar belowSubview:_maskView];
//    [_progressBar startShining];
    self.mpRecordVideoProgressBar = [[MPRecordVideoProgressBar alloc] initWithFrame:CGRectMake(0, 44+SCREEN_WIDTH, SCREEN_WIDTH, 7)];
    [self.view addSubview:self.mpRecordVideoProgressBar];
    

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


- (void)beginButtonTouchDown
{
    NSLog(@"开始录");
    [self.cameraManager startRecord:@""];
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
    
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
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
    if(![mediaType isEqualToString:@"public.movie"])
    {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        
        if (url && ![url isFileURL])
        {
            NSLog(@"Input file from camera is invalid.");
            return;
        }
        
        //        if ([self getVideoDuration:url] > kMaxRecordDuration)
        //        {
        //            NSString *ok = NSLocalizedString(@"ok", nil);
        //            NSString *error = NSLocalizedString(@"error", nil);
        //            NSString *fileLenHint = NSLocalizedString(@"fileLenHint", nil);
        //            NSString *seconds = NSLocalizedString(@"seconds", nil);
        //            NSString *hint = [fileLenHint stringByAppendingFormat:@" %d ", kMaxRecordDuration];
        //            hint = [hint stringByAppendingString:seconds];
        //            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error
        //                                                            message:hint
        //                                                           delegate:nil
        //                                                  cancelButtonTitle:ok
        //                                                  otherButtonTitles: nil];
        //            [alert show];
        //            [alert release];
        //
        //            return;
        //        }
        
//        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
//        {
//            self.fromSystemCamera = TRUE;
//        }
//        else if(picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum)
//        {
//            self.fromSystemCamera = FALSE;
//        }
//        else
//        {
//            self.fromSystemCamera = FALSE;
//        }
        
//        // Remove last file
//        if (self.videoPickURL && [self.videoPickURL isFileURL])
//        {
//            
//            
//            
//            if ([[NSFileManager defaultManager] removeItemAtURL:self.videoPickURL error:nil])
//            {
//                NSLog(@"Success for delete old pick file: %@", self.videoPickURL);
//            }
//            else
//            {
//                NSLog(@"Failed for delete old pick file: %@", self.videoPickURL);
//            }
//        }
//        
//        NSURL *sampleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"150511_JiveBike" ofType:@"mov"]];
//        
//        self.videoPickURL = sampleURL;
//        self.mp4OutputPath = [self getOutputFilePath];
//        self.hasVideo = YES;
//        
//        [self showVideoPlayView:FALSE];
//        
//        self.toggleEffects.enabled = TRUE;
//        self.frameScrollView.hidden = FALSE;
//        [self getPreviewImage:url];
    }
    else
    {
        NSLog(@"Error media type");
        return;
    }
}

- (CGFloat)getVideoDuration:(NSURL*)URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    
    return second;
}
- (void)photoMovieButtonClick
{
    
}


#pragma mark - MPCameraManagerRecorderDelegate
- (void)videoRecorder:(MPCameraManager *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL
{
    
    
        [self.mpRecordVideoProgressBar startRecordingAVideo];
    //    NSLog(@"正在录制视频: %@", fileURL);
    //
    //    [self.progressBar addProgressView];
    //    [_progressBar stopShining];
    //
    //    [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
}

- (void)videoRecorder:(MPCameraManager *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error
{
    //    if (error) {
    //        NSLog(@"录制视频错误:%@", error);
    //    } else {
    //        NSLog(@"录制视频完成: %@", outputFileURL);
    //    }
    //
    //
    //    if (totalDur >= MAX_VIDEO_DUR) {
    //        [self pressOKButton];
    //    }
    
    [_mpRecordVideoProgressBar stopRecordingAVideo];
}

- (void)videoRecorder:(MPCameraManager *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error
{
    //    if (error) {
    //        NSLog(@"删除视频错误: %@", error);
    //    } else {
    //        NSLog(@"删除了视频: %@", fileURL);
    //        NSLog(@"现在视频长度: %f", totalDur);
    //    }
    //
    //    if ([_recorder getVideoCount] > 0) {
    //        [_deleteButton setStyle:DeleteButtonStyleNormal];
    //    } else {
    //        [_deleteButton setStyle:DeleteButtonStyleDisable];
    //    }
    //
    //    _okButton.enabled = (totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(MPCameraManager *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur
{
    
    //    NSLog(@"%f", videoDuration);
        [_mpRecordVideoProgressBar setLastProgressToWidth:videoDuration / 10 * _mpRecordVideoProgressBar.frame.size.width];
    //
    //    _okButton.enabled = (videoDuration + totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(MPCameraManager *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL
{
    //    [_hud hide:YES];
    //    self.isProcessingData = NO;
    //    PlayViewController *playCon = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil withVideoFileURL:outputFileURL];
    //    [self.navigationController pushViewController:playCon animated:YES];
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
