//
//  TabBarItem.m
//  ImitationWeChat
//
//  Created by wany on 15/7/17.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import "TabBarItem.h"

@implementation TabBarItem
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.userInteractionEnabled = NO;
        
        
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor grayColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:10.f];
        
        [self addSubview:_button];
        [self addSubview:_label];
        
        _labelNormalColor = [UIColor grayColor];
        _labelHighLightColor = RGBCOLOR(234, 64, 123);
    }
    return self;
}
-(void)setLabelNormalColor:(UIColor *)labelNormalColor{
    _labelNormalColor = labelNormalColor;
    _label.textColor = labelNormalColor;
}
-(void)setLabelHighLightColor:(UIColor *)labelHighLightColor{
    _labelHighLightColor = labelHighLightColor;
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    _button.selected = selected;
    if (_button.selected) {
        _label.textColor = _labelHighLightColor;
    }else{
        _label.textColor = _labelNormalColor;
    }
}

@end
