//
//  NSString+Time.m
//  lilworld
//
//  Created by xwmedia01 on 15/10/27.
//  Copyright © 2015年 zp. All rights reserved.
//
#import "NSDateFormatter+Locale.h"

#import "NSString+Time.h"

@implementation NSString (Time)

+ (NSString *)dateString
{
    //获取当前时间
    NSDate *now = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];

    int year = (int)[dateComponent year];
    int month = (int)[dateComponent month];
    int day = (int)[dateComponent day];
    int hour = (int)[dateComponent hour];
    int minute = (int)[dateComponent minute];
//    int second = [dateComponent second];

    NSString *str = [NSString stringWithFormat:@"%i年%i月%i日\n%i:%i", year, month, day, hour,minute];
    return str;
}

+ (NSString *)dateStringWith:(NSString *)s
{
    //获取当前时间
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:s.doubleValue];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    int year = (int)[dateComponent year];
    int month = (int)[dateComponent month];
    int day = (int)[dateComponent day];
    double hour = [dateComponent hour];
    double minute = [dateComponent minute];
    
    NSString *str = [NSString stringWithFormat:@"%i年%i月%i日\n%02.0f:%02.0f", year, month, day, hour,minute];
    return str;
}

/**
 *  1k = 1000 (1千)
 *  1m = 1000000 (1百万)
 *  1b = 100000000 (1亿)
 */
+ (NSString *)standardLittleStarScore:(NSString *)score
{
    NSString *tempStarScoreString = score;
    float valueScore = score.floatValue;

    //显示k的时候
    if (valueScore > 999 && valueScore < 1000000) {
        tempStarScoreString = [NSString stringWithFormat:@"%@k", [self notRounding:valueScore/1000.0 afterPoint:1]];
    }
    
    //显示m的时候
    if (valueScore > 999999) {
        tempStarScoreString = [NSString stringWithFormat:@"%@m", [self notRounding:valueScore/1000000.0 afterPoint:1]];
    }
    
    return tempStarScoreString;
}

+ (NSString *)notRounding:(float)price afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

// 是否是闰年
+(int)bissextile:(int)year {
    if ((year%4==0 && year %100 !=0) || year%400==0) {
        return 366;
    }else {
        return 365;
    }
    return 365;
}


+(NSString *)getTimeWithContentFormat:(NSString *)format DateStr:(NSString *)str{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithSafeLocale];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    
    //输出格式
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:localTimeZone];
    NSString *dateString = [dateFormatter stringFromDate:[self getLocalDateFormateUTCDateStr:str]];
    
    return dateString;
}

//将date转换为月日
+(NSString *)getLocalDateFormateUTCAndDate:(NSDate *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithSafeLocale];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    
    //输出格式
    [dateFormatter setDateFormat:@"MM-dd"];
    [dateFormatter setTimeZone:localTimeZone];
    NSString *dateString = [dateFormatter stringFromDate:utcDate];
    
    return dateString;
}

//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+(NSDate *)getLocalDateFormateUTCDateStr:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithSafeLocale];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    
    NSString *str = utcDate;
    
    if (![utcDate hasSuffix:@"+0000"]) {
        str = [utcDate stringByAppendingString:@"+0000"];
    }
    
    
    
    NSDate *dateFormatted = [dateFormatter dateFromString:str];
    
    return dateFormatted;
}

/*处理返回应该显示的时间*/
+ (NSString *) returnUploadTime:(NSString *)timeStr
{

    
    NSString *resultTimeString = [self getTimeWithContentFormat:@"yyyy-MM-dd HH:mm:ss" DateStr:timeStr];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[dateFormatter dateFromString:resultTimeString];
  
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *returnTimeString=@"";
    
    NSTimeInterval cha= (int)now-late;
    
    //60s 内
    if (cha <60) {
        returnTimeString = @"刚刚";
    }
    
    //一小时内
    else if (cha >= 60 && cha < 3600)
        
    {
        
        returnTimeString = [NSString stringWithFormat:@"%f", cha/60];
        
        returnTimeString=[NSString stringWithFormat:@"%i分钟前", returnTimeString.intValue];
        
    }
    //一小时 －>  一天24小时内
    else if (cha >= 3600 && cha < (3600 * 24))
        
    {
        
        returnTimeString = [NSString stringWithFormat:@"%f", cha/3600];
        
        returnTimeString=[NSString stringWithFormat:@"%i小时前", returnTimeString.intValue];
        
    }
    
    //一天24小时 －>  一月内
    else if (cha >= (3600 * 24) && cha < (3600 * 24 * 30))
        
    {
        
        returnTimeString = [NSString stringWithFormat:@"%f", cha/(3600 * 24)];
        
        returnTimeString=[NSString stringWithFormat:@"%i天前", returnTimeString.intValue];
        
    }

    
    //一月 -> 一年内
    else if (cha >= (3600 * 24 * 30) && cha < (3600 * 24 * 365))
        
    {
        
        returnTimeString = [NSString stringWithFormat:@"%f", cha/(3600 * 24 * 30)];
        
        returnTimeString=[NSString stringWithFormat:@"%i月前", returnTimeString.intValue];
        
    }
    
    //一年以上
    else if (cha >= (3600 * 24 * 365))
        
    {
        
        returnTimeString = [NSString stringWithFormat:@"%f", cha/(3600 * 24 * 365)];
        
        returnTimeString=[NSString stringWithFormat:@"%i年前", returnTimeString.intValue];
        
    }
    return returnTimeString;
}

+ (NSString *)getTimeWithFormat:(NSString *)format date:(NSDate *)date
{
    //实例化一个NSDateFormatter对象
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    
   
    if (format) {
        [dateFormatter setDateFormat:format];
    }else
    {
        [dateFormatter setDateFormat:@"HH:mm"]; 
    }
    
    //用[NSDate date]可以获取系统当前时间
    
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    //输出格式为：2010-10-27 10:22:13
    
    return currentDateStr;

}

@end
