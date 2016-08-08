//
//  MPNavigationBar.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/8.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPNavigationBar.h"

@interface MPNavigationBar()

@property (nonatomic) UIButton *backButton;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *nextButton;

@end

@implementation MPNavigationBar
@synthesize backButton;
@synthesize titleLabel;
@synthesize nextButton;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //关闭按钮
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"btn_bar_back_a"] forState:UIControlStateNormal];
        //    [backButton setImage:[UIImage imageNamed:@"btn_bar_back_b"] forState:UIControlStateHighlighted];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, 0, 80, 44);
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
        backButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 100, 44)];
        titleLabel.centerX = CGRectGetMaxX(self.bounds)/2;
        titleLabel.text = @"裁剪";
        titleLabel.textAlignment = 1;
        titleLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
        titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:titleLabel];
        
        
        //下一步
        nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton setImage:[UIImage imageNamed:@"btn_bar_next_a"] forState:UIControlStateNormal];
        //    [nextButton setImage:[UIImage imageNamed:@"btn_bar_next_b"] forState:UIControlStateHighlighted];
        [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        nextButton.frame = CGRectMake(SCREEN_WIDTH-80, 0, 80, 44);
        nextButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
        nextButton.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
        nextButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [nextButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextButton];

    }
    return self;
}

- (void)backButtonClick
{
    
}

- (void)nextButtonClick
{
    
}

@end
