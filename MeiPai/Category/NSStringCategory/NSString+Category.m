//
//  NSString+Category.m
//  lilworld
//
//  Created by xwmedia01 on 16/6/16.
//  Copyright © 2016年 zp. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)
/**
 *  返回重复字符的location
 *
 *  @param text     初始化的字符串
 *  @param findText 查找的字符
 *
 *  @return 返回重复字符的location
 */
- (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText
{
    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:20];

    if (findText == nil && [findText isEqualToString:@""]) {
        return nil;
    }
    NSRange rang = [text rangeOfString:findText];
    if (rang.location != NSNotFound && rang.length != 0) {
        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];

        NSRange rang1 = {0,0};
        NSInteger location = 0;
        NSInteger length = 0;
        for (int i = 0;; i++)
        {
            if (0 == i) {
                location = rang.location + rang.length;
                length = text.length - rang.location - rang.length;
                rang1 = NSMakeRange(location, length);
            }else
            {
                location = rang1.location + rang1.length;
                length = text.length - rang1.location - rang1.length;
                rang1 = NSMakeRange(location, length);
            }
            rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
            if (rang1.location == NSNotFound && rang1.length == 0) {
                break;
            }else
                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];
        }
        return arrayRanges;
    }

    return nil;
}

- (void)findSameStringPostion:(NSString *)contentString AttributedString:(NSMutableAttributedString *)attributedString
{
    //1.建立正则表达式的匹配
    //    NSString *pattern = @"@(\\S+)($|\\s)";
    
    int asciiCode = 8197;
    NSString *string = [NSString stringWithFormat:@"%c", asciiCode];
    
    NSString *pattern = [NSString stringWithFormat:@"@([^%@]+)(%@)",string,string];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:kNilOptions error:nil];
    
    
    //2.将满足正则表达式的字段挑出来
    NSArray *match = [regex matchesInString:contentString
                                    options:NSMatchingReportCompletion
                                      range:NSMakeRange(0, [contentString length])];
    
    NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont systemFontOfSize:13.0],NSFontAttributeName,
                                   [UIColor getColor:@"3DC2D5"],NSForegroundColorAttributeName, nil];
    
    //set or return nsrange array
    if(match.count != 0)
    {
        for (NSTextCheckingResult *matc in match)
        {
            NSRange range = [matc range];
            
            [attributedString setAttributes:attributeDict range:range];
        }
    }
}



- (CGSize)CalculationStringSizeInView:(UIView *)showView space:(CGFloat)space
{
    if (![NSString isNotEmptyString:self]) {
        return CGSizeZero;
    }
    if ([showView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)showView;
        
        CGSize size = CGSizeMake(showView.width,MAXFLOAT); //设置一个行高上限
        NSDictionary *attribute = @{NSFontAttributeName: label.font};
        CGSize labelsize = [self boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine| NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        labelsize.height += space;
        return labelsize;
    }
    return CGSizeZero;
}

- (CGSize)CalculationStringSizeWithWidth:(CGFloat)showWidth font:(UIFont *)showFont space:(CGFloat)space
{
    if (![NSString isNotEmptyString:self]) {
        return CGSizeZero;
    }
    CGSize size = CGSizeMake(showWidth,MAXFLOAT); //设置一个行高上限
    NSDictionary *attribute = @{NSFontAttributeName: showFont};
    CGSize labelsize = [self boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine| NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    labelsize.height += space;
    return labelsize;

}

/**
 *  视频片段合成后本地文件名字
 */
+ (NSString *)getVideoMergeFilePathString;
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[MergeDictionaryPath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    return fileName;
}



/**
 *  视频片段本地存储文件名
 */
+ (NSString *)getVideoSaveFilePathString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[ClipsDictionaryPath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];

    return fileName;
}

@end
