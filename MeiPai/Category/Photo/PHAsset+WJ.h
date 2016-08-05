//
//  PHAsset+WJ.h
//  PhotoDemo
//
//  Created by ljjun on 15/9/23.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (WJ)
/**
 *  获取最新一张图片
 */
+ (PHAsset *)latestAsset;
@end
