//
//  WJAsset.h
//  PhotoDemo
//
//  Created by ljjun on 15/9/23.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAsset;
@class PHAsset;
@interface WJAsset : NSObject
@property (assign, nonatomic, readonly) NSTimeInterval creationTimeInterval;//创建时间戳
@property (strong, nonatomic, readonly, nonnull) UIImage *image;//原图
/**
 *  初始化
 *
 *  @param asset 相片信息 ALAsset PHAsset
 *
 *  @return
 */
- (instancetype _Nonnull)initWithALAsset:(ALAsset * _Nonnull)asset;
- (instancetype _Nonnull)initWithPHAsset:(PHAsset * _Nonnull)asset image:(UIImage * _Nonnull)image;
- (instancetype _Nonnull)initWithCreation:(NSTimeInterval)creation image:(UIImage * _Nonnull)image;
@end
