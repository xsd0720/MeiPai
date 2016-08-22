//
//  WHPhotoPreviewController.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHPhotoPreviewController : UIViewController
@property (nonatomic, strong) NSArray *photoArr;                ///< All photos / 所有图片的数组
@property (nonatomic, strong) NSMutableArray *selectedPhotoArr; ///< Current selected photos / 当前选中的图片数组
@property (nonatomic, assign) NSInteger currentIndex;           ///< Index of the photo user click / 用户点击的图片的索引
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;       ///< If YES,return original photo / 是否返回原图

/// Return the new selected photos / 返回最新的选中图片数组
@property (nonatomic, copy) void (^returnNewSelectedPhotoArrBlock)(NSMutableArray *newSeletedPhotoArr, BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^okButtonClickBlock)(NSMutableArray *newSeletedPhotoArr, BOOL isSelectOriginalPhoto);
@end
