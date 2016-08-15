//
//  MPEditVideoSwitch.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/15.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPEditVideoSwitch : UIControl

@property (strong, nonatomic) UIButton *lvJingButton;
@property (strong, nonatomic) UIButton *mvButton;

@property (strong, nonatomic) UIView *cursorLineView;

@property (assign, nonatomic) int selectedIndex;


@end
