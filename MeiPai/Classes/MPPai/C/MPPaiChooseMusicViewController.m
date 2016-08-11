//
//  MPPaiChooseMusicViewController.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/11.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPPaiChooseMusicViewController.h"

static NSString *MusicChooseCellIdentifier = @"MusicChooseCellIdentifier";

@interface MusicChooseCell : UITableViewCell

@property (nonatomic, strong) UILabel *accessoryLabel;

@property (nonatomic, assign) BOOL  hasClick;


@end


@implementation MusicChooseCell

- (UILabel *)accessoryLabel
{
    if (!_accessoryLabel) {
        _accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _accessoryLabel.text = @"愉悦";
        _accessoryLabel.font = [UIFont systemFontOfSize:15];
        _accessoryLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _accessoryLabel.textAlignment = 2;
    }
    return _accessoryLabel;
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.accessoryView = self.accessoryLabel;
    }
    return self;
}

- (void)setHasClick:(BOOL)hasClick
{
    _hasClick = hasClick;
    if (hasClick) {
        self.textLabel.textColor = PINKCOLOR;
    }else
    {
        self.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
}

@end

@interface MPPaiChooseMusicViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *chooseMusicTableView;

@property (nonatomic, strong) NSMutableArray *musicSourceArray;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


@end

@implementation MPPaiChooseMusicViewController


/**
 *  懒加载tableiview
 */
- (UITableView *)chooseMusicTableView {
    if (!_chooseMusicTableView) {
        _chooseMusicTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [self.view addSubview:_chooseMusicTableView];
        
        _chooseMusicTableView.separatorInset = UIEdgeInsetsZero;
        _chooseMusicTableView.separatorColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
        
        _chooseMusicTableView.frame = Rect(0, STATUS_AND_NAV_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT- STATUS_AND_NAV_BAR_HEIGHT);
        
        _chooseMusicTableView.dataSource = self;
        _chooseMusicTableView.delegate = self;
        _chooseMusicTableView.tableFooterView = [UIView new];
        _chooseMusicTableView.backgroundColor = self.view.backgroundColor;
        
        // 设置cell的重用
        [_chooseMusicTableView registerClass:[MusicChooseCell class] forCellReuseIdentifier:MusicChooseCellIdentifier];
        
    }
    return _chooseMusicTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNav];
    
    [self configData];
}

- (void)setupNav
{
    self.view.backgroundColor = RGBCOLOR(25, 24, 36);;
    
    UIButton *overButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overButton setImage:[UIImage imageNamed:@"icon_follow_check"] forState:UIControlStateNormal];
    [overButton setImage:[UIImage imageNamed:@"icon_follow_check"] forState:UIControlStateHighlighted];
    [overButton setTitle:@"完成" forState:UIControlStateNormal];
    [overButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [overButton setTitleColor:RGB(141, 141, 142) forState:UIControlStateHighlighted];
    overButton.frame = CGRectMake(SCREEN_WIDTH-100, 20, 80, 44);
    overButton.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    overButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [overButton addTarget:self action:@selector(overButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:overButton];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 100, 44)];
    titleLabel.centerX = CGRectGetMaxX(self.view.bounds)/2;
    titleLabel.text = @"选择音乐";
    titleLabel.textAlignment = 1;
    titleLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:titleLabel];
    
}

- (void)configData
{
    
    
//    [[NSBundle mainBundle] pathForResource:@"KT Mix" ofType:@"mp3"]
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSBundle mainBundle].bundlePath error:nil];
    self.musicSourceArray = [NSMutableArray array];
    [self.musicSourceArray addObject:@"无音乐"];
    [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *pathExtension = [obj pathExtension];
        if ([pathExtension isEqualToString:@"mp3"] || [pathExtension isEqualToString:@"caf"]) {
            [self.musicSourceArray addObject:obj];
        }
    }];
    
    [self.chooseMusicTableView reloadData];
    
}

- (void)overButtonClick
{
    
    if (_audioPlayer) {
        [_audioPlayer stop];
    }
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.musicSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:MusicChooseCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.musicSourceArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *visiableCell = [tableView visibleCells];
    [visiableCell enumerateObjectsUsingBlock:^(MusicChooseCell *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hasClick = NO;
    }];
    
    MusicChooseCell *cell = (MusicChooseCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.hasClick = YES;
    
    if (self.chooseMusicBlock) {
        self.chooseMusicBlock(cell.textLabel.text);
    }
    if (![cell.textLabel.text isEqualToString:@"无音乐"]) {
        NSString *musicFilePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:cell.textLabel.text];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:musicFilePath] error:nil];
        //    _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
  
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
