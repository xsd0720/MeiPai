//
//  UIColor+Category.h
//  ImitationWeChat
//
//  Created by xwmedia01 on 16/1/22.
//  Copyright © 2016年 wany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Category)
-(BOOL)isDarkColor:(UIColor *)newColor;

+ (UIColor *)getColor:(NSString *)stringToConvert;
@end
