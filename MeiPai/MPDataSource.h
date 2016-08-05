//
//  MPDataSource.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/4.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DS        [MPDataSource shareInstance]


@interface MPDataSource : NSObject


/*
 MyTabBarViewController
 */
@property (nonatomic,strong) NSArray *tabbarNormalImageArray;
@property (nonatomic,strong) NSArray *tabbarHlImageArray;
@property (nonatomic,strong) NSArray *tabbarTitleArray;


/*
 @pragma: Initialize a singleton
 */
+(MPDataSource *)shareInstance;

@end
