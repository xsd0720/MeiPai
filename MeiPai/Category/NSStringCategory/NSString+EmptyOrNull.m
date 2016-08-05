//
//  NSString+EmptyOrNull.m
//  lilworld
//
//  Created by xwmedia02 on 15/9/1.
//  Copyright (c) 2015年 zp. All rights reserved.
//

#import "NSString+EmptyOrNull.h"

@implementation NSString (EmptyOrNull)

-(BOOL) isEmptyOrNull{
    
    if (!self) {
        // null object
        LWLog(@"本来就是空的");
        return true;
    } else {
        NSString *trimedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            LWLog(@"长度为0");
            return true;
        } else {
            // is neither empty nor null
            return false;
        }
    }
    LWLog(@"走方法");
}

+ (BOOL)isNotEmptyString:(NSString *)string{
    
    if (string == nil) {
        
        return NO;
        
    }
    
    if (string == NULL) {
        
        return NO;
        
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        
        return NO;
        
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        
        return NO;

    }
    
    return YES;
    
}

@end
