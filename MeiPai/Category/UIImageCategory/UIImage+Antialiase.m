//
//  UIImage+Antialiase.m
//  ImageAntialiase
//
//  Created by 谌启亮 on 12-10-25.
//  Copyright (c) 2012年 谌启亮. All rights reserved.
//

#import "UIImage+Antialiase.h"

@implementation UIImage (Antialiase)

//创建抗锯齿头像
- (UIImage*)antialiasedImage{
    return [self antialiasedImageOfSize:self.size scale:self.scale];
}

//创建抗锯齿头像,并调整大小和缩放比。
- (UIImage*)antialiasedImageOfSize:(CGSize)size scale:(CGFloat)scale{
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [self drawInRect:CGRectMake(1, 1, size.width-2, size.height-2)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//调节图片清晰度
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //绘图抗锯齿
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    //设置裁决区域
    CGRect rect = CGRectMake(1, 1, size.width-2.0f, size.height-2.0f);
    
    //裁决圆形(最大可裁决圆)
    CGContextAddEllipseInRect(context, rect);
    
    //执行裁决
    CGContextClip(context);
    
    //圆形画布绘制图像
    [img drawInRect:rect];
    
    //绘制图像
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}


//调节图片清晰度(全局)
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

//调节图片清晰度并且重绘制
+ (UIImage *)scaleToSize:(CGSize)size cut:(SaveType)type image:(UIImage *)img
{
    
    CGFloat width = CGImageGetWidth(img.CGImage);
    CGFloat height = CGImageGetHeight(img.CGImage);
    
    CGFloat originP = width/height;
    
    
    CGFloat x;
    CGFloat y;
    CGFloat h;
    CGFloat w;
    
    
    CGFloat pp = size.width/originP;
    if (pp < size.height) {
        pp = size.height*originP;
        
        x = -fabs(pp-size.width)/2;
        if (type == SaveTop) {
            x = 0;
        }else if (type == SaveBottom)
        {
            x = -fabs(pp-size.width);
        }
        
        y = 0;
        w = pp;
        h = size.height;
        
    }
    else
    {
        x = 0;
        y = -fabs(pp-size.height)/2;
        if (type == SaveTop) {
            y = 0;
        }else if (type == SaveBottom)
        {
            y = -fabs(pp-size.height);
        }
        w = size.width;
        h = pp;
        
    }
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef con = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(con, [UIColor whiteColor].CGColor);
    
    CGContextFillRect(con, CGRectMake(0, 0, size.width, size.height));
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(x, y, w, h)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage*)clipImageWithImage:(UIImage*)image inRect:(CGRect)rect {
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, rect, imageRef);
    
    UIImage* clipImage = [UIImage imageWithCGImage:imageRef];

    
    UIGraphicsEndImageContext();
    
    return clipImage;
    
}


@end
