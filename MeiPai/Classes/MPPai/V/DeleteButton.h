//
//  DeleteButton.h
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-14.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>

typedef enum {
    DeleteButtonStyleDelete,
    DeleteButtonStyleNormal,
    DeleteButtonStyleDisable,
}DeleteButtonStyle;

@interface DeleteButton : UIButton

@property (nonatomic, strong) NSString *normalImageName;
@property (nonatomic, strong) NSString *hightlightImageName;
@property (nonatomic, strong) NSString *disableImageName;

@property (assign, nonatomic) DeleteButtonStyle style;

- (void)setButtonStyle:(DeleteButtonStyle)style;
+ (DeleteButton *)getInstance;

@end
