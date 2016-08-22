//
//  WHImagePickerBottomView.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHAssetModel.h"
@interface WHImagePickerBottomView : UIView

@property (nonatomic, strong) UIButton *okButton;

- (void)addAssetModel:(WHAssetModel *)model;

- (NSMutableArray *)getAllSelectedImages;

@end
