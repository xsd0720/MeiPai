//
//  WHAssetCell.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>
#define WHALBUMCELLIDENTIFIER @"WHALBUMCellIDENTIFIER"
#define WHASSETCELLIDENTIFIER @"WHASSETCELLIDENTIFIER"


typedef enum : NSUInteger {
    WHAssetCellTypePhoto = 0,
    WHAssetCellTypeLivePhoto,
    WHAssetCellTypeVideo,
    WHAssetCellTypeAudio,
} WHAssetCellType;

@class WHAssetModel;
@interface WHAssetCell : UICollectionViewCell

@property (nonatomic, nonatomic) UIButton *selectPhotoButton;
@property (nonatomic, strong) WHAssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) WHAssetCellType type;

@end


@class WHAlbumModel;

@interface WHAlbumCell : UITableViewCell

@property (nonatomic, strong) WHAlbumModel *model;

@end
