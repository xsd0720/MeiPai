//
//  WHImagePickerController.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHImagePickerBottomView.h"

#define BOTTOMVIEWHEIGHT    140

#define kNaviBarAndBottonBarBgColor  ([UIColor colorWithRed:(19/255.0) green:(17/255.0) blue:(27/255.0) alpha:1.0])
#define kOKButtonTitleColorNormal    ([UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0])
#define kOKButtonTitleColorDisabled  ([UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5])
#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)

@protocol WHImagePickerControllerDelegate;

@interface WHImagePickerController : UINavigationController

/// Use this init method / 用这个初始化方法
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<WHImagePickerControllerDelegate>)delegate hasBottomView:(BOOL)isHasBottomView;

/// Default is 9 / 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxImagesCount;

/// Default is YES.if set NO, the original photo button will hide. user can't picking original photo.
/// 默认为YES，如果设置为NO,原图按钮将隐藏，用户不能选择发送原图
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;

/// Default is YES.if set NO, user can't picking video.
/// 默认为YES，如果设置为NO,用户将不能选择发送视频
@property (nonatomic, assign) BOOL allowPickingVideo;

- (void)showAlertWithTitle:(NSString *)title;
- (void)showProgressHUD;
- (void)hideProgressHUD;

// The picker does not dismiss itself; when client dismisses it these handle will be called.
// The second array will be a empty array if user not picking original photo.
// 这个照片选择器不会自己dismiss，用户dismiss这个选择器的时候，会执行下面的handle
// 如果用户没有选择发送原图,第二个数组将是空数组
@property (nonatomic, copy) void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets);
@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets,NSArray<NSDictionary *> *infos);
@property (nonatomic, copy) void (^imagePickerControllerDidCancelHandle)();
// If user picking a video, this handle will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
@property (nonatomic, copy) void (^didFinishPickingVideoHandle)(UIImage *coverImage,id asset);

@property (nonatomic, weak) id<WHImagePickerControllerDelegate> pickerDelegate;

@property (nonatomic, strong) WHImagePickerBottomView *bottomView;

@end


@protocol WHImagePickerControllerDelegate <NSObject>
@optional
// The picker does not dismiss itself; the client dismisses it in these callbacks.
// Assets will be a empty array if user not picking original photo.
// 这个照片选择器不会自己dismiss，用户dismiss这个选择器的时候，会走下面的回调
// 如果用户没有选择发送原图,Assets将是空数组
- (void)imagePickerController:(WHImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets;
- (void)imagePickerController:(WHImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos;
- (void)imagePickerControllerDidCancel:(WHImagePickerController *)picker;
// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(WHImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset;
@end



@interface WHAlbumPickerController : UIViewController

@end
