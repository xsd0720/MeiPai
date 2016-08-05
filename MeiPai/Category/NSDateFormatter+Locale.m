//
//  NSDateFormatter+Locale.m
//  lilworld
//
//  Created by wany on 16/4/13.
//  Copyright © 2016年 zp. All rights reserved.
//

#import "NSDateFormatter+Locale.h"

@implementation NSDateFormatter (Locale)

- (id)initWithSafeLocale {
    static NSLocale* en_US_POSIX = nil;
    self = [self init];
    if (en_US_POSIX == nil) {
        en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    [self setLocale:en_US_POSIX];
    return self;
}

@end
