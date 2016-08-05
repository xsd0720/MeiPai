//
//  NSString+md5.h
//  firstRun
//
//  Created by xwmedia01 on 15/7/29.
//  Copyright (c) 2015年 xwmedia01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface NSString (md5)
-(NSString *) md5HexDigest;
@end
