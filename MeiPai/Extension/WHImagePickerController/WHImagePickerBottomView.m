//
//  WHImagePickerBottomView.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "WHImagePickerBottomView.h"
#import "WHImageManager.h"

#define WHImagePickerBottomViewCellSize    75
#define CELLIDENTIIFER  @"CELLIDENTIIFER"


@protocol WHImagePickerBottomViewCellDelegate <NSObject>

- (void)didClickClose:(WHAssetModel *)model indexPathRow:(NSInteger)indexPathRow;

@end

@interface WHImagePickerBottomViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) WHAssetModel *model;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) id<WHImagePickerBottomViewCellDelegate> delegate;

@property (nonatomic, assign) NSInteger  indexPathRow;

@end

@implementation WHImagePickerBottomViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 65, 65)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(50, 0, 20, 20);
        [_closeButton setImage:[UIImage imageNamed:@"btn_login_close_a"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
    }
    return self;
}

- (void)setModel:(WHAssetModel *)model {
    _model = model;
    [[WHImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info) {
        self.imageView.image = photo;
    }];
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)closeButtonClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickClose:indexPathRow:)]) {
        [self.delegate didClickClose:self.model indexPathRow:self.indexPathRow];
    }
}

@end


@interface WHImagePickerBottomView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WHImagePickerBottomViewCellDelegate>

@property (nonatomic, strong) UILabel *promptLabel;


@property (nonatomic, strong) UICollectionView *mainCollectionView;

@property (nonatomic, strong) NSMutableArray *datasourceArray;

@end

@implementation WHImagePickerBottomView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.datasourceArray = [[NSMutableArray alloc] init];
        
        [self addSubview:self.promptLabel];
        [self addSubview:self.okButton];
        
    }
    return self;
}


- (UILabel *)promptLabel
{
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 150, 15)];
        _promptLabel.font = [UIFont systemFontOfSize:12];
        _promptLabel.text = @"支持3～6张照片";
        _promptLabel.textColor = RGB(125, 124, 132);
    }
    return _promptLabel;
}


- (UIButton *)okButton
{
    if (!_okButton) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(SCREEN_WIDTH-115, 10, 105, 28);
        _okButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _okButton.layer.cornerRadius = 5;
        [_okButton setTitle:@"开始制作" forState:UIControlStateNormal];
        [_okButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okButton setBackgroundColor:RGB(103, 103, 103)];
   
        _okButton.enabled = NO;
    }
    return _okButton;
}

/**
 *  加载 tableView 视图
 */
- (UICollectionView *)mainCollectionView{
    if (!_mainCollectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(WHImagePickerBottomViewCellSize, WHImagePickerBottomViewCellSize);
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 0);
        
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, WHImagePickerBottomViewCellSize) collectionViewLayout:layout];
        [self addSubview:_mainCollectionView];
        //        _editVideoCollectionView.alwaysBounceVertical = YES;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.backgroundColor = [UIColor clearColor];
        
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        
        
        //  注册重用池
        [_mainCollectionView registerClass:[WHImagePickerBottomViewCell class] forCellWithReuseIdentifier:CELLIDENTIIFER];
        [_mainCollectionView setExclusiveTouch:YES];
        
    }
    return _mainCollectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  self.datasourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WHImagePickerBottomViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELLIDENTIIFER forIndexPath:indexPath];
    cell.delegate = self;
    cell.image = self.datasourceArray[indexPath.row];
    cell.indexPathRow = indexPath.row;
    return cell;
}

- (void)addAssetModel:(WHAssetModel *)model
{
    [[WHImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info) {
        [self.datasourceArray addObject:photo];
        [self.mainCollectionView reloadData];
       [self updateOKButton];

    }];
}

- (void)didClickClose:(WHAssetModel *)model indexPathRow:(NSInteger)indexPathRow
{
    [self.datasourceArray removeObjectAtIndex:indexPathRow];
    [self.mainCollectionView reloadData];
    
    [self updateOKButton];
}

- (void)updateOKButton
{
    if (self.datasourceArray.count >= 3) {
        self.okButton.enabled = YES;
        [self.okButton setBackgroundColor:RGB(80, 176, 140)];
    }else
    {
        self.okButton.enabled = YES;
        [self.okButton setBackgroundColor:RGB(103, 103, 103)];
    }
    if (self.datasourceArray.count > 0) {
        [_okButton setTitle:[NSString stringWithFormat:@"开始制作(%zd)", self.datasourceArray.count] forState:UIControlStateNormal];
    }else
    {
        [_okButton setTitle:@"开始制作(%zd)" forState:UIControlStateNormal];
    }
    
}

- (NSMutableArray *)getAllSelectedImages
{
    return self.datasourceArray;
}

@end
