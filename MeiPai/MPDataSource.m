//
//  MPDataSource.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/4.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPDataSource.h"

@implementation MPDataSource

+(MPDataSource *)shareInstance{
    static MPDataSource *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MPDataSource alloc]init];
    });
    return _instance;
}


-(NSArray *)tabbarNormalImageArray{
    return @[@"icon_left_homepage_a",@"tabbar_contacts",@"tabbar_discover",@"tabbar_me", @"tabbar_me"];
}
-(NSArray *)tabbarHlImageArray{
    return @[@"icon_left_homepage_b",@"tabbar_contactsHL",@"tabbar_discoverHL",@"tabbar_meHL", @"tabbar_me"];
}
-(NSArray *)tabbarTitleArray{
    return @[@"美拍",@"我的关注",@"开始拍",@"最热话题", @"我"];
}


@end
