//
//  UIImage+Category.h
//  ImitationWeChat
//
//  Created by xwmedia01 on 16/1/18.
//  Copyright © 2016年 wany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Antialiase.h"
@interface UIImage (Category)

- (CGSize)limitMaxWidthHeight:(CGFloat)maxW maxH:(CGFloat)maxH;

+ (UIImage *)drawDashLineRect:(CGRect)rect;

+ (UIImage *)createRoundedRectImage:(UIImage *)image withSize:(CGSize)size withRadius:(NSInteger)radius;

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size;

+ (UIImage *)generateBarCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height;

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size;

/**
 *  获取视频封面，本地视频，网络视频都可以用
 *
 *  @param videoURL video的Url
 */
+ (void)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)tt completion:(void(^)(UIImage *image))completion;

@end
