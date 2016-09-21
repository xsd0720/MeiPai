//
//  MyTabBarController.m
//  FitTiger
//
//  Created by 李清青 on 15/6/2.
//  Copyright (c) 2015年 PanghuKeji. All rights reserved.
//

#import "MyTabBarController.h"
#import "MPHomeViewController.h"
#import "MPFollowViewController.h"
#import "MPPaiViewController.h"
#import "MPHotViewController.h"
#import "MPMeViewController.h"
#import "MyNavViewController.h"


#import "TabBarItem.h"
#define BUTTONWIDTH         (SCREEN_WIDTH/self.viewControllers.count)
#define TABBARITEM_LABELHEIGHT      12


@interface MyTabBarController ()
{
    MPHomeViewController    *homeVC;
    MPFollowViewController  *followVC;
    MPPaiViewController     *paiVC;
    MPHotViewController     *hotVC;
    MPMeViewController      *meVC;

    
    UIImageView *tabbarImageView;

}
@property (nonatomic,strong) NSMutableArray *tabbarButtonArray;

@end

@implementation MyTabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTabBarBackground];
    [self createViewControllers];
    [self createTabBarItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)createTabBarBackground{
    UIImageView  *customView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.tabBar.frame.size.width, self.tabBar.frame.size.height)];
    customView.userInteractionEnabled = YES;
    customView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    UIImage *tbbarBg = [UIImage imageWithContentsOfFile:@"btn_square_bg_b"];
    [tbbarBg stretchableImageWithLeftCapWidth:0.f topCapHeight:0.f];
    customView.image = tbbarBg;
    [self.tabBar addSubview:customView];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSLog(@"%@", path);
}

-(void)createTabBarItems{
    

    _tabbarButtonArray = [NSMutableArray array];
    for (int i=0 ; i<self.viewControllers.count; i++)
    {
        if (i == 2) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(buttonPaiClick:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(i*BUTTONWIDTH,0, BUTTONWIDTH, self.tabBar.frame.size.height);
            [button setImage:[UIImage imageNamed:@"tabbar_camera_a_64x49_"] forState:UIControlStateNormal];
            [self.tabBar addSubview:button];
            continue;
        }
        TabBarItem *tabbrItem = [[TabBarItem alloc] initWithFrame:CGRectMake(i*BUTTONWIDTH,0, BUTTONWIDTH, self.tabBar.frame.size.height)];
        [tabbrItem addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        

        tabbrItem.button.frame = CGRectMake(0,0, BUTTONWIDTH, self.tabBar.frame.size.height-TABBARITEM_LABELHEIGHT);
        [tabbrItem.button setImage:[UIImage imageNamed:DS.tabbarNormalImageArray[i]] forState:UIControlStateNormal];
        [tabbrItem.button setImage:[UIImage imageNamed:DS.tabbarHlImageArray[i]] forState:UIControlStateSelected];
        tabbrItem.label.text = DS.tabbarTitleArray[i];
        tabbrItem.label.frame  = CGRectMake(0, tabbrItem.frame.size.height-TABBARITEM_LABELHEIGHT, BUTTONWIDTH, 8);
        [self.tabBar addSubview:tabbrItem];

        
        tabbrItem.tag = i;

        [_tabbarButtonArray addObject:tabbrItem];
        if (tabbrItem.tag == self.selectedIndex) {
            tabbrItem.selected = YES;
        }
    }
}

-(void)buttonClick:(UIButton *)sender{
    
    if (sender.tag == self.selectedIndex) {
        return;
    }
    
    //选中当前
    [_tabbarButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *bt = (UIButton *)obj;
        bt.selected = NO;
    }];
    
    sender.selected = YES;
    self.selectedIndex = sender.tag;
}


- (void)buttonPaiClick:(UIButton *)button
{
   MPPaiViewController *paVC = [[MPPaiViewController alloc] init];
    [self presentViewController:paVC animated:YES completion:nil];
}


-(void)createViewControllers{
    
    //美拍
    homeVC = [[MPHomeViewController alloc] init];
    MyNavViewController *nc1=[[MyNavViewController alloc]initWithRootViewController:homeVC];
    
    //我的关注
    followVC = [[MPFollowViewController alloc]init];
    MyNavViewController *nc2=[[MyNavViewController alloc]initWithRootViewController:followVC];
    
    //美拍
    paiVC = [[MPPaiViewController alloc] init];
    MyNavViewController *nc3=[[MyNavViewController alloc]initWithRootViewController:paiVC];
    
    //最热话题
    hotVC = [[MPHotViewController alloc] init];
    MyNavViewController *nc4=[[MyNavViewController alloc]initWithRootViewController:hotVC];

    //我
    meVC = [[MPMeViewController alloc] init];
    MyNavViewController *nc5=[[MyNavViewController alloc]initWithRootViewController:meVC];
   
   
    self.viewControllers=@[nc1,nc2,nc3,nc4, nc5];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end




