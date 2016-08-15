//
//  MPEditVideoSwitch.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/15.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPEditVideoSwitch.h"

@implementation MPEditVideoSwitch

- (UIButton *)lvJingButton
{
    if (!_lvJingButton) {
        _lvJingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lvJingButton setTitle:@"滤镜" forState:UIControlStateNormal];
        [_lvJingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_lvJingButton setTitleColor:PINKCOLOR forState:UIControlStateSelected];
        _lvJingButton.frame = CGRectMake(0, 0, 60, 25);
        
        _lvJingButton.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [_lvJingButton addTarget:self action:@selector(lvJingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lvJingButton;
}

- (UIButton *)mvButton
{
    if (!_mvButton) {
        _mvButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mvButton setTitle:@"MV" forState:UIControlStateNormal];
        [_mvButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_mvButton setTitleColor:PINKCOLOR forState:UIControlStateSelected];
        _mvButton.frame = CGRectMake(CGRectGetMaxX(_lvJingButton.frame), 0, 60, 25);
        
        _mvButton.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [_mvButton addTarget:self action:@selector(mvButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mvButton;
}


- (UIView *)cursorLineView
{
    if (!_cursorLineView) {
        _cursorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds)-2, 60, 2)];
        _cursorLineView.backgroundColor = PINKCOLOR;
    }
    return _cursorLineView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.selectedIndex = 0;
        
        [self addSubview:self.lvJingButton];
        [self addSubview:self.mvButton];
        
        [self addSubview:self.cursorLineView];
        
    }
    return self;
}



- (void)lvJingButtonClick
{
    if (self.selectedIndex != 0) {
        self.selectedIndex = 0;
        [UIView animateWithDuration:0.1 animations:^{
            self.cursorLineView.originX = self.lvJingButton.originX;
        }];
        self.mvButton.selected = NO;
        self.lvJingButton.selected = YES;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


- (void)mvButtonClick
{
    if (self.selectedIndex != 1) {
        self.selectedIndex = 1;
        [UIView animateWithDuration:0.1 animations:^{
            self.cursorLineView.originX = self.mvButton.originX;
        }];
        self.mvButton.selected = YES;
        self.lvJingButton.selected = NO;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}

@end
