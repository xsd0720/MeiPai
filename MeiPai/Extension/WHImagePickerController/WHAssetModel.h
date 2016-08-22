//
//  WHAssetModel.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WHAssetModelMediaTypePhoto = 0,
    WHAssetModelMediaTypeLivePhoto,
    WHAssetModelMediaTypeVideo,
    WHAssetModelMediaTypeAudio
} WHAssetModelMediaType;

@class PHAsset;
@interface WHAssetModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) WHAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a asset
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(WHAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(WHAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end


@class PHFetchResult;
@interface WHAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

@end
