//
//  ALAsset+WJ.m
//  PhotoDemo
//
//  Created by ljjun on 15/9/23.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import "ALAsset+WJ.h"

@implementation ALAsset (WJ)

- (UIImage *)thumbnailImage {
    return [[UIImage alloc]initWithCGImage:[self aspectRatioThumbnail]];
}
- (UIImage *)originalImage {
    
    CGImageRef ref = [[self defaultRepresentation] fullScreenImage];
    return [[UIImage alloc]initWithCGImage:ref];
}
- (NSTimeInterval)createTimeInterval {
    return [[self valueForProperty:ALAssetPropertyDate] timeIntervalSince1970];
}

- (NSURL *)assetURL {
    return [self valueForProperty:ALAssetPropertyAssetURL];
}
@end
