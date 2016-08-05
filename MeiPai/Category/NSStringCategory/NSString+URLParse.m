//
//  NSString+URLParse.m
//  ImitationWeChat
//
//  Created by wany on 15/7/17.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import "NSString+URLParse.h"

@implementation NSString (URLParse)
//是否是url
+(BOOL)parseString:(NSString *)urlString{
    
    NSRegularExpression *regularexpressionURL = [[NSRegularExpression alloc]
                                                 
                                                 initWithPattern:@"http://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?"
                                                 
                                                 options:NSRegularExpressionCaseInsensitive
                                                 
                                                 error:nil];
    NSRegularExpression *regularexpressionURL2 = [[NSRegularExpression alloc]
                                                  
                                                  initWithPattern:@"https://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?"
                                                  
                                                  options:NSRegularExpressionCaseInsensitive
                                                  
                                                  error:nil];
    NSUInteger numberofMatchURL = [regularexpressionURL numberOfMatchesInString:urlString
                                   
                                                                        options:NSMatchingAnchored
                                   
                                                                          range:NSMakeRange(0, urlString.length)];
    NSUInteger numberofMatchURL2 = [regularexpressionURL2 numberOfMatchesInString:urlString
                                    
                                                                          options:NSMatchingAnchored
                                    
                                                                            range:NSMakeRange(0, urlString.length)];
    if(numberofMatchURL > 0||numberofMatchURL2>0) {
        return YES;
    }
    return NO;
}


+ (NSString *)notRounding:(float)price afterPoint:(int)position{

    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness: NO  raiseOnOverflow: NO  raiseOnUnderflow: NO  raiseOnDivideByZero: NO ];

    NSDecimalNumber *ouncesDecimal;

    NSDecimalNumber *roundedOunces;

    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];

    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

    return  [NSString stringWithFormat: @"%@" ,roundedOunces];

}

@end
