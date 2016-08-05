//
//  UIImage+imageNamed_Hack.m
//  ImitationWeChat
//
//  Created by wany on 14/12/12.
//  Copyright (c) 2014年 wany. All rights reserved.
//

#import "UIImage+imageNamed_Hack.h"

@implementation UIImage (imageNamed_Hack)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
//warining : Category is implementing a method which will also be implemented by its primary class
//+(UIImage *)imageNamed:(NSString *)name{
//    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], name]];
//}
#pragma clang diagnostic pop
@end
