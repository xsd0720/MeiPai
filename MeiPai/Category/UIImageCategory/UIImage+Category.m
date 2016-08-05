//
//  UIImage+Category.m
//  ImitationWeChat
//
//  Created by xwmedia01 on 16/1/18.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "UIImage+Category.h"
#import <AssetsLibrary/AssetsLibrary.h>
@implementation UIImage (Category)
+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top
{
    UIImage *image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * left topCapHeight:image.size.height * top];
}

/**
 *  根据颜色和大小获取Image
 *
 *  @param color 颜色
 *  @param size  大小
 *
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 *  根据图片和颜色返回一张加深颜色以后的图片
 */
+ (UIImage *)colorizeImage:(UIImage *)baseImage withColor:(UIColor *)theColor {
    
    UIGraphicsBeginImageContext(CGSizeMake(baseImage.size.width*2, baseImage.size.height*2));
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width * 2, baseImage.size.height * 2);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    
    [theColor set];
    CGContextFillRect(ctx, area);
    
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextDrawImage(ctx, area, baseImage.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
///**
// *  根据图片返回一张高斯模糊的图片
// *
// *  @param blur 模糊系数
// *
// *  @return 新的图片
// */
//- (UIImage *)boxblurImageWithBlur:(CGFloat)blur {
//    
//    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
//    UIImage* destImage = [UIImage imageWithData:imageData];
//    
//    
//    if (blur < 0.f || blur > 1.f) {
//        blur = 0.5f;
//    }
//    int boxSize = (int)(blur * 40);
//    boxSize = boxSize - (boxSize % 2) + 1;
//    
//    CGImageRef img = destImage.CGImage;
//    
//    vImage_Buffer inBuffer, outBuffer;
//    
//    vImage_Error error;
//    
//    void *pixelBuffer;
//    
//    
//    //create vImage_Buffer with data from CGImageRef
//    
//    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
//    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
//    
//    
//    inBuffer.width = CGImageGetWidth(img);
//    inBuffer.height = CGImageGetHeight(img);
//    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
//    
//    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
//    
//    //create vImage_Buffer for output
//    
//    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
//    
//    if(pixelBuffer == NULL)
//        NSLog(@"No pixelbuffer");
//    
//    outBuffer.data = pixelBuffer;
//    outBuffer.width = CGImageGetWidth(img);
//    outBuffer.height = CGImageGetHeight(img);
//    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
//    
//    // Create a third buffer for intermediate processing
//    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
//    vImage_Buffer outBuffer2;
//    outBuffer2.data = pixelBuffer2;
//    outBuffer2.width = CGImageGetWidth(img);
//    outBuffer2.height = CGImageGetHeight(img);
//    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
//    
//    //perform convolution
//    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
//    if (error) {
//        NSLog(@"error from convolution %ld", error);
//    }
//    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
//    if (error) {
//        NSLog(@"error from convolution %ld", error);
//    }
//    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
//    if (error) {
//        NSLog(@"error from convolution %ld", error);
//    }
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
//                                             outBuffer.width,
//                                             outBuffer.height,
//                                             8,
//                                             outBuffer.rowBytes,
//                                             colorSpace,
//                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
//    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
//    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
//    
//    //clean up
//    CGContextRelease(ctx);
//    CGColorSpaceRelease(colorSpace);
//    
//    free(pixelBuffer);
//    free(pixelBuffer2);
//    CFRelease(inBitmapData);
//    
//    CGImageRelease(imageRef);
//    
//    return returnImage;
//}
/**
 *  自由改变Image的大小
 *
 *  @param size 目的大小
 *
 *  @return 修改后的Image
 */
- (UIImage *)cropImageWithSize:(CGSize)size {
    
    float scale = self.size.width/self.size.height;
    CGRect rect = CGRectMake(0, 0, 0, 0);
    
    if (scale > size.width/size.height) {
        
        rect.origin.x = (self.size.width - self.size.height * size.width/size.height)/2;
        rect.size.width  = self.size.height * size.width/size.height;
        rect.size.height = self.size.height;
        
    }else {
        
        rect.origin.y = (self.size.height - self.size.width/size.width * size.height)/2;
        rect.size.width  = self.size.width;
        rect.size.height = self.size.width/size.width * size.height;
        
    }
    
    CGImageRef imageRef   = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}


- (CGSize)limitMaxWidthHeight:(CGFloat)maxW maxH:(CGFloat)maxH
{
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    
    //宽大于高
    if (w > h) {
        float scale = w/h;
        CGFloat resultW = MIN(maxW, w);
        CGFloat resultH = resultW/scale;
        return CGSizeMake(resultW, resultH);
    }
    //宽高相等
    else if(w == h)
    {
        float scale = 1;
        CGFloat resultW = MIN(maxW, w);
        CGFloat restultH = resultW/scale;
        return CGSizeMake(resultW, restultH);
    }
    //高大于宽
    else
    {
        float scale = h/w;
        CGFloat resultH = MIN(maxH, h);
        CGFloat resultW = resultH/scale;
        return  CGSizeMake(resultW, resultH);
    }

}

+ (UIImage *)drawDashLineRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);   //开始画线
    CGFloat lengths[] = {5,5};
    CGContextRef line = UIGraphicsGetCurrentContext();
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    CGContextSetStrokeColorWithColor(line, RGBCOLOR(208, 208, 208).CGColor);
    CGContextSetLineWidth(line, 3);
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    CGContextMoveToPoint(line, 0.0, 0.0);    //开始画线
    CGContextAddLineToPoint(line, rect.size.width, 0.0);
    CGContextStrokePath(line);
    UIImage *dashImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return dashImage;
}


#pragma mark - Private Methods
static void addRoundedRectToPath(CGContextRef contextRef, CGRect rect, float widthOfRadius, float heightOfRadius) {
     float fw, fh;
     if (widthOfRadius == 0 || heightOfRadius == 0)
        {
                CGContextAddRect(contextRef, rect);
                 return;
             }

     CGContextSaveGState(contextRef);
     CGContextTranslateCTM(contextRef, CGRectGetMinX(rect), CGRectGetMinY(rect));
     CGContextScaleCTM(contextRef, widthOfRadius, heightOfRadius);
     fw = CGRectGetWidth(rect) / widthOfRadius;
     fh = CGRectGetHeight(rect) / heightOfRadius;

     CGContextMoveToPoint(contextRef, fw, fh/2);  // Start at lower right corner
     CGContextAddArcToPoint(contextRef, fw, fh, fw/2, fh, 1);  // Top right corner
     CGContextAddArcToPoint(contextRef, 0, fh, 0, fh/2, 1); // Top left corner
     CGContextAddArcToPoint(contextRef, 0, 0, fw/2, 0, 1); // Lower left corner
     CGContextAddArcToPoint(contextRef, fw, 0, fw, fh/2, 1); // Back to lower right

     CGContextClosePath(contextRef);
     CGContextRestoreGState(contextRef);
}

 #pragma mark - Public Methods
+ (UIImage *)createRoundedRectImage:(UIImage *)image withSize:(CGSize)size withRadius:(NSInteger)radius {
    // the size of CGContextRef
   
        float scaleFactor = 1;
    int w = size.width*scaleFactor;
    int h = size.height*scaleFactor;
   
//    UIImage *img = image;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
//    CGRect rect = CGRectMake(0, 0, w, h);
//    
//    CGContextBeginPath(context);
//    addRoundedRectToPath(context, rect, radius, radius);
//    CGContextClosePath(context);
//    CGContextClip(context);
//    CGContextSetShouldAntialias(context, YES);
////    CGContextSetAllowAntialiasing(context, YES);
//    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
////    CGContextDrawImage(context, layer.bounds, flipImage
//    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    img = [UIImage imageWithCGImage:imageMasked];
//    
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    CGImageRelease(imageMasked);
//    
//    return img;

//    CGRect extent = CGRectIntegral(image.extent);
//    CGFloat scale = MIN(size.width/CGRectGetWidth(extent), size.width/CGRectGetHeight(extent));
//
   
//    addRoundedRectToPath(contextRef, rect, 5, 5);
//    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
//    CGContextScaleCTM(contextRef, 2, 2);
    
//    CGContextTranslateCTM(contextRef, 0, h);

//    CGContextScaleCTM(contextRef, 1.0, -1.0);

//    CGContextDrawImage(contextRef, CGRectMake(0, 0, w, h), image.CGImage);
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    CGRect rrr = CGRectMake(0, 0, w, h);
//    CGContextAddEllipseInRect(contextRef, rrr);
//    CGContextClip(contextRef);
    [[UIBezierPath bezierPathWithRoundedRect:rrr cornerRadius:radius] addClip];

    [image drawInRect:rrr];
    UIImage *dashImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return dashImage;


}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);
    
    CGImageRef imageRefResized = CGBitmapContextCreateImage(contextRef);
    
    //Release
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return [UIImage imageWithCGImage:imageRefResized];
    
}

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size {
    
    // 生成条形码图片
    
    CIImage *qrcodeImage;
    
    NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    qrcodeImage = [filter outputImage];
    
    CGFloat scaleX = size.width / qrcodeImage.extent.size.width; // extent 返回图片的frame
    
    CGFloat scaleY = size.height / qrcodeImage.extent.size.height;
    
    CIImage *transformedImage = [qrcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
    
}


+ (UIImage *)generateBarCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height {
    
    // 生成二维码图片
    
    CIImage *barcodeImage;
    
    NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    
    barcodeImage = [filter outputImage];
    
    // 消除模糊
    
    CGFloat scaleX = width / barcodeImage.extent.size.width; // extent 返回图片的frame
    
    CGFloat scaleY = height / barcodeImage.extent.size.height;
    
    CIImage *transformedImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
    
}



/**
 *  获取视频封面，本地视频，网络视频都可以用
 *
 *  @param videoURL video的Url
 */
+ (void)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)tt completion:(void(^)(UIImage *image))completion{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        NSParameterAssert(asset);
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
        gen.appliesPreferredTrackTransform = YES;
        gen.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        CMTime time = CMTimeMakeWithSeconds(tt, NSEC_PER_SEC);
        
        NSError *thumbnailImageGenerationError = nil;
        
        CMTime actualTime;
        CGImageRef thumbnailImageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&thumbnailImageGenerationError];
        
        if(!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        
        UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(thumbnailImage);
            }
        });
    });
}


@end
