//
//  WHPhotoPreviewCell.h
//  WHImagePickerController
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//



#import <UIKit/UIKit.h>

@class WHAssetModel;
@interface WHPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) WHAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)();

@end
