//
//  UIView+SubView.m
//  ImitationWeChat
//
//  Created by xwmedia01 on 16/7/15.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "UIView+SubView.h"

@implementation UIView (SubView)
- (UIView *)findSubview:(NSString *)name resursion:(BOOL)resursion
{
    Class class = NSClassFromString(name);
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:class]) {
            return subview;
        }
    }
    
    if (resursion) {
        for (UIView *subview in self.subviews) {
            UIView *tempView = [subview findSubview:name resursion:resursion];
            if (tempView) {
                return tempView;
            }
        }
    }
    
    return nil;
}
@end
