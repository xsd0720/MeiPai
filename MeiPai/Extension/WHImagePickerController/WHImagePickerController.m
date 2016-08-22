//
//  WHImagePickerController.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/18.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "WHImagePickerController.h"

#import "WHPhotoPickerController.h"
#import "WHPhotoPreviewController.h"
#import "WHAssetModel.h"
#import "WHAssetCell.h"
#import "UIView+Layout.h"
#import "WHImageManager.h"



@interface WHImagePickerController () {
    BOOL _pushToPhotoPickerVc;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLable;
}
@end

@implementation WHImagePickerController

- (WHImagePickerBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[WHImagePickerBottomView alloc] init];
        _bottomView.tag = 101;
        [self.view addSubview:_bottomView];
        _bottomView.backgroundColor = RGBCOLOR(18, 18, 26);
    }
    return _bottomView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR(42, 42, 55);
    
    if (iOS7Later) {
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.barTintColor = kNaviBarAndBottonBarBgColor;
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[WHImagePickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[WHImagePickerController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];

    
    
    NSMutableDictionary *titleTextAttrs = [NSMutableDictionary dictionary];
    titleTextAttrs[NSForegroundColorAttributeName] = RGBCOLOR(163, 163, 169);
    [self.navigationBar setTitleTextAttributes:titleTextAttrs];
    
    self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-BOTTOMVIEWHEIGHT, SCREEN_WIDTH, BOTTOMVIEWHEIGHT);
    
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<WHImagePickerControllerDelegate>)delegate hasBottomView:(BOOL)isHasBottomView {
    WHAlbumPickerController *albumPickerVc = [[WHAlbumPickerController alloc] init];
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        _allowPickingOriginalPhoto = YES;
        _allowPickingVideo = YES;
        
        if (![[WHImageManager manager] authorizationStatusAuthorized]) {
            UILabel *tipLable = [[UILabel alloc] init];
            tipLable.frame = CGRectMake(8, 0, self.view.width - 16, 300);
            tipLable.textAlignment = NSTextAlignmentCenter;
            tipLable.numberOfLines = 0;
            tipLable.font = [UIFont systemFontOfSize:16];
            tipLable.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            tipLable.text = [NSString stringWithFormat:@"请在%@的\"设置-隐私-照片\"选项中，\r允许%@访问你的手机相册。",[UIDevice currentDevice].model,appName];
            [self.view addSubview:tipLable];
        } else {
            _pushToPhotoPickerVc = YES;
            if (_pushToPhotoPickerVc) {
                WHPhotoPickerController *photoPickerVc = [[WHPhotoPickerController alloc] init];
                [[WHImageManager manager] getCameraRollAlbum:self.allowPickingVideo completion:^(WHAlbumModel *model) {
                    photoPickerVc.model = model;
                    [self pushViewController:photoPickerVc animated:YES];
                    _pushToPhotoPickerVc = NO;
                }];
            }
        }
    }
    return self;
}

- (void)showAlertWithTitle:(NSString *)title {
    if (iOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
    }
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake((self.view.width - 120) / 2, (self.view.height - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLable = [[UILabel alloc] init];
        _HUDLable.frame = CGRectMake(0,40, 120, 50);
        _HUDLable.textAlignment = NSTextAlignmentCenter;
        _HUDLable.text = @"正在处理...";
        _HUDLable.font = [UIFont systemFontOfSize:15];
        _HUDLable.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLable];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (iOS7Later) viewController.automaticallyAdjustsScrollViewInsets = NO;
    if (self.childViewControllers.count > 0) {
//        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 44, 44)];
//        [backButton setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
//        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
//        [backButton setTitle:@"返回" forState:UIControlStateNormal];
//        backButton.titleLabel.font = [UIFont systemFontOfSize:15];
//        [backButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    [super pushViewController:viewController animated:animated];
}

@end


@interface WHAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
    NSMutableArray *_albumArr;
}

@end

@implementation WHAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"相簿";
    //    UIButton * button_cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44.0f, 44.0f)];
    //    [button_cancel setTitle:@"取消" forState:UIControlStateNormal];
    //    [button_cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [button_cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    //        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button_cancel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.view.height -= BOTTOMVIEWHEIGHT;
    
    WHImagePickerController *imagePickerVc = (WHImagePickerController *)self.navigationController;
    [[WHImageManager manager] getAllAlbums:imagePickerVc.allowPickingVideo completion:^(NSArray<WHAlbumModel *> *models) {
        _albumArr = [NSMutableArray arrayWithArray:models];
        [self configTableView];
    }];
    
    WHPhotoPickerController *photoPickerVc = [[WHPhotoPickerController alloc] init];
    photoPickerVc.model = [WHImageManager manager].savePhotosModel;
    [self.navigationController pushViewController:photoPickerVc animated:NO];
}

- (void)configTableView {

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATIONBAR_HEIGHT, self.view.width, self.view.height-NAVIGATIONBAR_HEIGHT) style:UITableViewStylePlain];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = RGBCOLOR(44, 42, 54);
    _tableView.backgroundColor = RGBCOLOR(42, 42, 55);
    [_tableView registerClass:[WHAlbumCell class] forCellReuseIdentifier:WHALBUMCELLIDENTIFIER];
    [self.view addSubview:_tableView];
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

#pragma mark - UITableViewDataSource && Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WHAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:WHALBUMCELLIDENTIFIER forIndexPath:indexPath];
    cell.model = _albumArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WHPhotoPickerController *photoPickerVc = [[WHPhotoPickerController alloc] init];
    photoPickerVc.model = _albumArr[indexPath.row];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
