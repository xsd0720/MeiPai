//
//  TabBarItem.h
//  ImitationWeChat
//
//  Created by wany on 15/7/17.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import <UIKit/UIKit.h>
#define LabelHeight 12
@interface TabBarItem : UIButton
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UILabel *label;

@property (nonatomic,strong) UIColor *labelNormalColor;
@property (nonatomic,strong) UIColor *labelHighLightColor;
@property (nonatomic,assign) CGFloat fontSize;

@end
