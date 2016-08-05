//
//  WJPhotoTool.m
//  PhotoDemo
//
//  Created by ljjun on 15/9/23.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import "WJPhotoTool.h"

#import "ALAsset+WJ.h"
#import "ALAssetsLibrary+WJ.h"
#import "PHAsset+WJ.h"


@implementation WJPhotoTool
+ (void)latestAsset:(WJPhotoCallBack _Nullable)callBack {
    NSLog(@"system -- %@",[UIDevice currentDevice].systemVersion);
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {//判断适配
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                PHAsset *asset = [PHAsset latestAsset];
                // 在资源的集合中获取第一个集合，并获取其中的图片
                if (asset) {
                    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
                    [imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        WJAsset *a = nil;
                        if (imageData) {
                            UIImage * image = [UIImage imageWithData:imageData];
                            a = [[WJAsset alloc]initWithPHAsset:asset image:image];
                        }
                        if (callBack) {
                            callBack(a);
                        }
                    }];
                } else {
                    if (callBack) {
                        callBack(nil);
                    }
                }
            } else {
                NSLog(@"status %ld",(long)status);
                if (callBack) {
                    callBack(nil);
                }
            }
        }];
    } else {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
        [library latestAsset:^(ALAsset * _Nullable asset, NSError * _Nullable error) {
            WJAsset *a = nil;
            if (asset) {
                a = [[WJAsset alloc]initWithALAsset:asset];
            } else {
                NSLog(@"---- %@",error.localizedDescription);
            }
            if (callBack) {
                callBack(a);
            }
        }];
    }
}
@end
