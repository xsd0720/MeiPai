//
//  WHImageManager.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WHAlbumModel,WHAssetModel;
@interface WHImageManager : NSObject
@property (nonatomic, strong) WHAlbumModel *savePhotosModel;
+ (instancetype)manager;

/// Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;

/// Get Album 获得相册/相册数组
- (void)getCameraRollAlbum:(BOOL)allowPickingVideo completion:(void (^)(WHAlbumModel *model))completion;
- (void)getAllAlbums:(BOOL)allowPickingVideo completion:(void (^)(NSArray<WHAlbumModel *> *models))completion;

/// Get Asset 获得Asset数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<WHAssetModel *> *models))completion;

/// Get photo 获得照片
- (void)getPostImageWithAlbumModel:(WHAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;
- (void)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

/// Get video 获得视频
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;
@end
