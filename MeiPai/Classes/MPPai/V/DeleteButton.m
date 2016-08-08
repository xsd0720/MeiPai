//
//  DeleteButton.m
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-14.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "DeleteButton.h"

#define DELETE_BTN_NORMAL_IAMGE @"btn_del_a"
#define DELETE_BTN_DELETE_IAMGE @"btn_del_active_a"
#define DELETE_BTN_DISABLE_IMAGE @"record_delete_disable.png"

@interface DeleteButton ()


@end

@implementation DeleteButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize
{
    [self setImage:[UIImage imageNamed:DELETE_BTN_NORMAL_IAMGE] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:DELETE_BTN_DISABLE_IMAGE] forState:UIControlStateDisabled];
}

+ (DeleteButton *)getInstance
{
    DeleteButton *deleteButton = [[DeleteButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    return deleteButton;
}

- (void)setButtonStyle:(DeleteButtonStyle)style
{
    self.style = style;
    switch (style) {
        case DeleteButtonStyleNormal:
        {
            self.enabled = YES;
            [self setImage:[UIImage imageNamed:@"btn_del_a"] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"btn_del_b"] forState:UIControlStateHighlighted];
        }
            break;
        case DeleteButtonStyleDisable:
        {
            self.enabled = NO;
            [self setImage:[UIImage imageNamed:@"btn_del_c"] forState:UIControlStateNormal];
        }
            break;
        case DeleteButtonStyleDelete:
        {
            self.enabled = YES;
            [self setImage:[UIImage imageNamed:@"btn_del_active_a"] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"btn_del_active_b"] forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
}

@end
