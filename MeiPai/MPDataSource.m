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
    return @[@"tabbar_home_a_28x28_",@"tabbar_friend_a_28x28_",@"tabbar_camera_a_64x49_",@"tabbar_explore_a_28x28_", @"tabbar_user_a_28x28_"];
}
-(NSArray *)tabbarHlImageArray{
    return @[@"tabbar_home_b_28x28_",@"tabbar_friend_b_28x28_",@"tabbar_camera_b_64x49_",@"tabbar_explore_b_28x28_", @"tabbar_user_b_28x28_"];
}
-(NSArray *)tabbarTitleArray{
    return @[@"美拍",@"我的关注",@"开始拍",@"最热话题", @"我"];
}


@end
