//
//  UIImage+CutImage.m
//  demo
//
//  Created by wany on 15/2/11.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import "UIImage+CutImage.h"

@implementation UIImage (CutImage)
// 1返回一个使用RGBA通道的位图上下文
static CGContextRef CreateRGBABitmapContext (CGImageRef inImage)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData; //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage); //获取横向的像素点的个数
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow = (int)pixelsWide * 4; //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    bitmapByteCount = (int)(bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
    colorSpace = CGColorSpaceCreateDeviceRGB();//创建依赖于设备的RGB通道
    //分配足够容纳图片字节数的内存空间
    bitmapData = malloc( bitmapByteCount );
    //创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedLast);
    //Core Foundation中通过含有Create、Alloc的方法名字创建的指针，需要使用CFRelease()函数释放
    CGColorSpaceRelease( colorSpace );
    return context;
}
//传入png图片  返回 签名处图
+ (CGPoint)processImage:(UIImage*)inImage
{
    //    unsigned char *imgPixel = RequestImagePixelData(inImage);
    CGImageRef img = [inImage CGImage];
    CGSize size = [inImage size];
    //使用上面的函数创建上下文
    CGContextRef cgctx = CreateRGBABitmapContext(img);
    CGRect rect = {{0,0},{size.width, size.height}};
    //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
    CGContextDrawImage(cgctx, rect, img);
    unsigned char *imgPixel = CGBitmapContextGetData (cgctx);
    
    
    CGImageRef inImageRef = [inImage CGImage];
    size_t w = CGImageGetWidth(inImageRef);
    size_t h = CGImageGetHeight(inImageRef);
    int wOff = 0;
    int pixOff = 0;
    
    int minx = size.width;
    int maxx = 0;
    int miny =  size.height;
    int maxy = 0;
    
    
    
    //双层循环按照长宽的像素个数迭代每个像素点
    for(GLuint y = 0;y< h;y++)
    {
        pixOff = wOff;
        
        for (GLuint x = 0; x<w; x++)
        {
                        int red = (unsigned char)imgPixel[pixOff];
                        int green = (unsigned char)imgPixel[pixOff+1];
                        int blue = (unsigned char)imgPixel[pixOff+2];
            
            
            
            int alpha=(unsigned char)imgPixel[pixOff+3];
            
            NSLog(@"%i    %i     %i     %i", red, green, blue, alpha);
            
            if (alpha != 0) {
//                //                              NSLog(@"%i",alpha);
//                imgPixel[pixOff] = 255;
//                imgPixel[pixOff+1] = 255;
//                imgPixel[pixOff+2] = 255;
                
                //                imgPixel[pixOff+3] = 0;
                if (x<minx) {
                    minx = x;
                }
                if (x>maxx) {
                    maxx = x;
                }
                if (y<miny) {
                    miny = y;
                    
                }
                if (y>maxy) {
                    maxy = y;
                }
                
                
                
            }
            pixOff += 4;
        }
        wOff += w * 4;
    }
//    NSInteger dataLength = w*h* 4;
//    //下面的代码创建要输出的图像的相关参数
//    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
//    // prep the ingredients
//    int bitsPerComponent = 8;
//    int bitsPerPixel = 32;
//    size_t bytesPerRow = 4 * w;
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
//    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
//    
//    //创建要输出的图像
//    CGImageRef imageRef = CGImageCreate(w, h,
//                                        bitsPerComponent,
//                                        bitsPerPixel,
//                                        bytesPerRow,
//                                        colorSpaceRef,
//                                        bitmapInfo,
//                                        provider,
//                                        NULL, NO, renderingIntent);
//    
//    UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
    
    
//    CGColorSpaceRelease(colorSpaceRef);
//    CGDataProviderRelease(provider);
    //    280    396     534    672
//    NSLog(@"%i   %i   %i   %i    ",minx,maxx,miny,maxy);

    return CGPointMake(minx, miny);
    
    //    UIImage *cutimageResult = [self imageFromImage:inImage inRect:CGRectMake(minx, miny, maxx-minx, maxy-miny)];
//
//    return cutimageResult;
}
+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
//    [UIImagePNGRepresentation(newImage) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:<#(NSString *)#>] atomically:<#(BOOL)#>]
    
    
    return newImage;
}
@end
