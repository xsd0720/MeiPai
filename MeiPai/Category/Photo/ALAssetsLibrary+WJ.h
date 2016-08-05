//
//  ALAssetsLibrary+WJ.h
//  PhotoDemo
//
//  Created by ljjun on 15/9/23.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (WJ)
/**
 *  获取最新一张图片
 *
 *  @param block 回调
 */
- (void)latestAsset:(void(^_Nullable)(ALAsset * _Nullable asset,NSError *_Nullable error)) block;
@end
