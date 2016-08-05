//
//  UIImage+type.m
//  lilworld
//
//  Created by xwmedia02 on 15/9/22.
//  Copyright © 2015年 zp. All rights reserved.
//

#import "UIImage+type.h"

@implementation UIImage (type)

+(UIImage *)imageWithName:(NSString *)name{
    NSString *type ;
    if (IS_IPHONE5) {
        type = @"5";
    }else if (IS_IPhone6){
        type = @"6";
    }else{
        type = @"6+";
    }
    NSString *str = [NSString stringWithFormat:@"%@_%@",name,type];
    
    UIImage *image = [UIImage imageNamed:str];
    return image;
}

@end
