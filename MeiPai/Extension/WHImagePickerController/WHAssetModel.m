//
//  WHAssetModel.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "WHAssetModel.h"

@implementation WHAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(WHAssetModelMediaType)type{
    WHAssetModel *model = [[WHAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(WHAssetModelMediaType)type timeLength:(NSString *)timeLength {
    WHAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end



@implementation WHAlbumModel


@end
