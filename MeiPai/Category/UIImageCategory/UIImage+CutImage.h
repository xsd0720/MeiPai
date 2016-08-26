//
//  UIImage+CutImage.h
//  demo
//
//  Created by wany on 15/2/11.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CutImage)
//传入png图片  返回 坐标
+ (UIImage *)processImage:(UIImage*)inImage;

@end
