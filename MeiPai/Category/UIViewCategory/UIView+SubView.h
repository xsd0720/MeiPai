//
//  UIView+SubView.h
//  ImitationWeChat
//
//  Created by xwmedia01 on 16/7/15.
//  Copyright © 2016年 wany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SubView)

/**
 *  param:name :will find view name
 *  para:resursion: is deep search
 **/

- (UIView *)findSubview:(NSString *)name resursion:(BOOL)resursion;
@end
