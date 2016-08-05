//
//  UIImage+Antialiase.h
//  ImageAntialiase
//
//  Created by 谌启亮 on 12-10-25.
//  Copyright (c) 2012年 谌启亮. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, SaveType) {
    SaveCenter = 0,
    SaveTop = 1,
    SaveBottom = 2,
};

@interface UIImage (Antialiase)

//创建抗锯齿头像
- (UIImage*)antialiasedImage;

//创建抗锯齿头像,并调整大小和缩放比。
- (UIImage*)antialiasedImageOfSize:(CGSize)size scale:(CGFloat)scale;

//调节图片清晰度
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

//调节图片清晰度(全局)
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

////调节图片清晰度并且重绘制
//- (UIImage *)scaleAndCutSize:(CGSize)size;

+ (UIImage *)scaleToSize:(CGSize)size cut:(SaveType)type image:(UIImage *)img;
@end
