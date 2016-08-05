//
//  NSString+EmptyOrNull.h
//  lilworld
//
//  Created by xwmedia02 on 15/9/1.
//  Copyright (c) 2015年 zp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EmptyOrNull)

-(BOOL) isEmptyOrNull;

+ (BOOL)isNotEmptyString:(NSString *)string;

@end
