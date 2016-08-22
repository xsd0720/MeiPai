//
//  WHPhotoPickerController.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "WHPhotoPickerController.h"

#import "WHImagePickerController.h"
#import "WHPhotoPreviewController.h"
#import "WHAssetCell.h"
#import "WHAssetModel.h"
#import "UIView+Layout.h"
#import "WHImageManager.h"
#import "WHVideoPlayerController.h"

@interface WHPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate> {
    UICollectionView *_collectionView;
    NSMutableArray *_photoArr;
    
    UIButton *_previewButton;
    UIButton *_okButton;
    UIImageView *_numberImageView;
    UILabel *_numberLable;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLable;
    
    BOOL _isSelectOriginalPhoto;
    BOOL _shouldScrollToBottom;
}
@property (nonatomic, strong) NSMutableArray *selectedPhotoArr;
@end

@implementation WHPhotoPickerController

- (NSMutableArray *)selectedPhotoArr {
    if (_selectedPhotoArr == nil) _selectedPhotoArr = [NSMutableArray array];
    return _selectedPhotoArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.height -= BOTTOMVIEWHEIGHT;
    
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = RGBCOLOR(42, 42, 55);;
    self.navigationItem.title = _model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    WHImagePickerController *imagePickerVc = (WHImagePickerController *)self.navigationController;
    [[WHImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:imagePickerVc.allowPickingVideo completion:^(NSArray<WHAssetModel *> *models) {
        _photoArr = [NSMutableArray arrayWithArray:models];
        [self configCollectionView];
    }];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 2;
    CGFloat count = 4;
    CGFloat itemWH = (self.view.width-(count-1)*margin)/count;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATIONBAR_HEIGHT, SCREEN_WIDTH, self.view.height-NAVIGATIONBAR_HEIGHT) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = self.view.backgroundColor;

    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[WHAssetCell class] forCellWithReuseIdentifier:WHASSETCELLIDENTIFIER];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_shouldScrollToBottom && _photoArr.count > 0) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(_photoArr.count - 1) inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        _shouldScrollToBottom = NO;
    }
    
}



#pragma mark - Click Event

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    WHImagePickerController *imagePickerVc = (WHImagePickerController *)self.navigationController;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [imagePickerVc.pickerDelegate imagePickerControllerDidCancel:imagePickerVc];
    }
    if (imagePickerVc.imagePickerControllerDidCancelHandle) {
        imagePickerVc.imagePickerControllerDidCancelHandle();
    }
}

- (void)previewButtonClick {
    WHPhotoPreviewController *photoPreviewVc = [[WHPhotoPreviewController alloc] init];
    photoPreviewVc.photoArr = [NSArray arrayWithArray:self.selectedPhotoArr];
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)okButtonClick {
    WHImagePickerController *imagePickerVc = (WHImagePickerController *)self.navigationController;
    [imagePickerVc showProgressHUD];
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    
    for (NSInteger i = 0; i < _selectedPhotoArr.count; i++) {
        WHAssetModel *model = _selectedPhotoArr[i];
        [[WHImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info) {
            if (photo) [photos addObject:photo];
            if (info) [infoArr addObject:info];
            if (_isSelectOriginalPhoto) [assets addObject:model.asset];
            if (photos.count < _selectedPhotoArr.count) return;
            
            if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:)]) {
                [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingPhotos:photos sourceAssets:assets];
            }
            if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:infos:)]) {
                [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingPhotos:photos sourceAssets:assets infos:infoArr];
            }
            if (imagePickerVc.didFinishPickingPhotosHandle) {
                imagePickerVc.didFinishPickingPhotosHandle(photos,assets);
            }
            if (imagePickerVc.didFinishPickingPhotosWithInfosHandle) {
                imagePickerVc.didFinishPickingPhotosWithInfosHandle(photos,assets,infoArr);
            }
            [imagePickerVc hideProgressHUD];
        }];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WHAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WHASSETCELLIDENTIFIER forIndexPath:indexPath];
    WHAssetModel *model = _photoArr[indexPath.row];
    cell.model = model;
    typeof(cell) weakCell = cell;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        // 1. cancel select / 取消选择
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            [self.selectedPhotoArr removeObject:model];
            [self refreshBottomToolBarStatus];
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            WHImagePickerController *imagePickerVc = (WHImagePickerController *)self.navigationController;
            if (self.selectedPhotoArr.count < imagePickerVc.maxImagesCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [self.selectedPhotoArr addObject:model];
                [self refreshBottomToolBarStatus];
            } else {
                [imagePickerVc showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片",imagePickerVc.maxImagesCount]];
            }
        }
        [UIView showOscillatoryAnimationWithLayer:_numberImageView.layer type:WHOscillatoryAnimationToSmaller];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WHAssetModel *model = _photoArr[indexPath.row];
//    if (model.type == WHAssetModelMediaTypeVideo) {
//        if (_selectedPhotoArr.count > 0) {
//            WHImagePickerController *imagePickerVc = (WHImagePickerController *)self.navigationController;
//            [imagePickerVc showAlertWithTitle:@"选择照片时不能选择视频"];
//        } else {
//            WHVideoPlayerController *videoPlayerVc = [[WHVideoPlayerController alloc] init];
//            videoPlayerVc.model = model;
//            [self.navigationController pushViewController:videoPlayerVc animated:YES];
//        }
//    } else {
//        WHPhotoPreviewController *photoPreviewVc = [[WHPhotoPreviewController alloc] init];
//        photoPreviewVc.photoArr = _photoArr;
//        photoPreviewVc.currentIndex = indexPath.row;
//        [self pushPhotoPrevireViewController:photoPreviewVc];
//    }
}

#pragma mark - Private Method

- (void)refreshBottomToolBarStatus {
    _previewButton.enabled = self.selectedPhotoArr.count > 0;
    _okButton.enabled = self.selectedPhotoArr.count > 0;
    
    _numberImageView.hidden = _selectedPhotoArr.count <= 0;
    _numberLable.hidden = _selectedPhotoArr.count <= 0;
    _numberLable.text = [NSString stringWithFormat:@"%zd",_selectedPhotoArr.count];
    
    _originalPhotoButton.enabled = _selectedPhotoArr.count > 0;
    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLable.hidden = (!_originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)pushPhotoPrevireViewController:(WHPhotoPreviewController *)photoPreviewVc {
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    photoPreviewVc.selectedPhotoArr = self.selectedPhotoArr;
    photoPreviewVc.returnNewSelectedPhotoArrBlock = ^(NSMutableArray *newSelectedPhotoArr,BOOL isSelectOriginalPhoto) {
        _selectedPhotoArr = newSelectedPhotoArr;
        _isSelectOriginalPhoto = isSelectOriginalPhoto;
        [_collectionView reloadData];
        [self refreshBottomToolBarStatus];
    };
    photoPreviewVc.okButtonClickBlock = ^(NSMutableArray *newSelectedPhotoArr,BOOL isSelectOriginalPhoto){
        _selectedPhotoArr = newSelectedPhotoArr;
        _isSelectOriginalPhoto = isSelectOriginalPhoto;
        [self okButtonClick];
    };
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)getSelectedPhotoBytes {
    [[WHImageManager manager] getPhotosBytesWithArray:_selectedPhotoArr completion:^(NSString *totalBytes) {
        _originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
