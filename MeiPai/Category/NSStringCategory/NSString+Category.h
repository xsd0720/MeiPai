//
//  NSString+Category.h
//  lilworld
//
//  Created by xwmedia01 on 16/6/16.
//  Copyright © 2016年 zp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSString+EmptyOrNull.h"

@interface NSString (Category)
//获取重复字符串位置
- (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText;
- (void)findSameStringPostion:(NSString *)contentString AttributedString:(NSMutableAttributedString *)attributedString;


- (CGSize)CalculationStringSizeInView:(UIView *)showView space:(CGFloat)space;

- (CGSize)CalculationStringSizeWithWidth:(CGFloat)showWidth font:(UIFont *)showFont space:(CGFloat)space;


/**
 *  视频片段合成后本地文件名
 */
+ (NSString *)getVideoMergeFilePathString;


/**
 *  视频片段本地存储文件名
 */
+ (NSString *)getVideoSaveFilePathString;


@end
