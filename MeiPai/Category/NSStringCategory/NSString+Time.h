//
//  NSString+Time.h
//  lilworld
//
//  Created by xwmedia01 on 15/10/27.
//  Copyright © 2015年 zp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Time)

+ (NSString *)dateString;

+ (NSString *)dateStringWith:(NSString *)s;

+ (NSString *)standardLittleStarScore:(NSString *)score;

/*处理返回应该显示的时间*/
+ (NSString *) returnUploadTime:(NSString *)timeStr;

+ (NSString *)getTimeWithFormat:(NSString *)format date:(NSDate *)date;

@end
