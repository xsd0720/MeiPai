//
//  NSString+URLParse.h
//  ImitationWeChat
//
//  Created by wany on 15/7/17.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLParse)

+(BOOL)parseString:(NSString *)urlString;

+ (NSString *)notRounding:(float)price afterPoint:(int)position;

@end
