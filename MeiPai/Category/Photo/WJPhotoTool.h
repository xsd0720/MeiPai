//
//  WJPhotoTool.h
//  PhotoDemo
//
//  Created by ljjun on 15/9/23.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJAsset.h"

typedef void(^WJPhotoCallBack)(WJAsset *_Nullable asset);
@interface WJPhotoTool : NSObject
+ (void)latestAsset:(WJPhotoCallBack _Nullable)callBack;
@end
