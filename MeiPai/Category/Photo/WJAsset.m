//
//  WJAsset.m
//  PhotoDemo
//
//  Created by ljjun on 15/9/23.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import "WJAsset.h"
#import "ALAsset+WJ.h"
#import "PHAsset+WJ.h"

@implementation WJAsset
- (instancetype _Nonnull)initWithALAsset:(ALAsset * _Nonnull)asset {
    return [self initWithCreation:asset.createTimeInterval image:asset.originalImage];
}
- (instancetype _Nonnull)initWithPHAsset:(PHAsset * _Nonnull)asset image:(UIImage * _Nonnull)image {
    return [self initWithCreation:asset.creationDate.timeIntervalSince1970 image:image];
}
- (instancetype _Nonnull)initWithCreation:(NSTimeInterval)creation image:(UIImage * _Nonnull)image {
    if (self = [super init] ) {
        _image = image;
        _creationTimeInterval = creation;
    }
    return self;
}
@end
