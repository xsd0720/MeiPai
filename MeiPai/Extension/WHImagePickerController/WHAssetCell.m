//
//  WHAssetCell.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "WHAssetCell.h"

#import "WHAssetModel.h"
#import "UIView+Layout.h"
#import "WHImageManager.h"
#import "WHImagePickerController.h"

@interface WHAssetCell ()
@property (nonatomic)  UIImageView *imageView;       // The photo / 照片
@property (nonatomic)  UIImageView *selectImageView;
@property (nonatomic)  UIView *bottomView;
@property (nonatomic)  UILabel *timeLength;

@end

@implementation WHAssetCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:_selectImageView];
        
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-20, frame.size.width, 20)];
        [self addSubview:_bottomView];
        
        
        self.timeLength.font = [UIFont boldSystemFontOfSize:11];
    }
    return self;
}


- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}



- (void)setModel:(WHAssetModel *)model {
    _model = model;
    [[WHImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info) {
        self.imageView.image = photo;
    }];
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamed:@"photo_sel_photoPickerVc"] : [UIImage imageNamed:@"photo_def_photoPickerVc"];
    self.type = WHAssetCellTypePhoto;
    if (model.type == WHAssetModelMediaTypeLivePhoto)      self.type = WHAssetCellTypeLivePhoto;
    else if (model.type == WHAssetModelMediaTypeAudio)     self.type = WHAssetCellTypeAudio;
    else if (model.type == WHAssetModelMediaTypeVideo) {
        self.type = WHAssetCellTypeVideo;
        self.timeLength.text = model.timeLength;
    }
}

- (void)setType:(WHAssetCellType)type {
    _type = type;
    if (type == WHAssetCellTypePhoto || type == WHAssetCellTypeLivePhoto) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
    }
}

- (IBAction)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:@"photo_sel_photoPickerVc"] : [UIImage imageNamed:@"photo_def_photoPickerVc"];
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:WHOscillatoryAnimationToBigger];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end

@interface WHAlbumCell ()
@property (nonatomic) UIImageView *posterImageView;
@property (nonatomic) UILabel *titleLable;
@end

@implementation WHAlbumCell

- (UIImageView *)posterImageView
{
    if (!_posterImageView) {
        _posterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        _posterImageView.clipsToBounds = YES;
        [self addSubview:_posterImageView];
    }
    return _posterImageView;
}
//
//- (UILabel *)titleLable
//{
//    if (!_titleLable) {
//        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
//        [self addSubview:self.titleLable];
//    }
//    return _titleLable;
//}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = RGBCOLOR(34, 32, 44);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont systemFontOfSize:15];
        
        self.detailTextLabel.textColor = RGBCOLOR(140, 138, 149);
        self.detailTextLabel.font = [UIFont systemFontOfSize:10];
    }
    return self;
}

- (void)setModel:(WHAlbumModel *)model {
    _model = model;
    
    self.textLabel.text = model.name;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%zd",model.count];
    [[WHImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.posterImageView.image = postImage;
        });
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.posterImageView.frame = CGRectMake(self.posterImageView.originX, self.posterImageView.originY, CGRectGetMaxY(self.bounds), CGRectGetMaxY(self.bounds));
    
    self.textLabel.originX = CGRectGetMaxX(self.posterImageView.frame)+18;
    self.detailTextLabel.originX = CGRectGetMaxX(self.posterImageView.frame)+18;
    
    
}

///// For fitting iOS6
//- (void)layoutSubviews {
//    if (iOS7Later) [super layoutSubviews];
//}
//
//- (void)layoutSublayersOfLayer:(CALayer *)layer {
//    if (iOS7Later) [super layoutSublayersOfLayer:layer];
//}


@end
