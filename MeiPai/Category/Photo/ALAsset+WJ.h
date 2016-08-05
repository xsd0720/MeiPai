//
//  ALAsset+WJ.h
//  PhotoDemo
//
//  Created by ljjun on 15/9/23.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import <UIKit/UIKit.h>

@interface ALAsset (WJ)
- (UIImage *)thumbnailImage;
- (UIImage *)originalImage;
- (NSTimeInterval)createTimeInterval;
- (NSURL *)assetURL;
@end
