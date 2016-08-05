//
//  UINavigationItem+correct_offset.m
//  ImitationWeChat
//
//  Created by xwmedia01 on 16/1/18.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "UINavigationItem+correct_offset.h"
#define  ios7 ([[[UIDevice currentDevice] systemVersion] floatValue]>= 7.0 ?YES:NO)
@implementation UINavigationItem (correct_offset)
- (void)addLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
{
    if ( ios7 ) {
        // Add a spacer on when running lower than iOS 7.0
        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ] initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                                                                          target : nil action : nil ];
        negativeSpacer. width = - 10 ;
        [ self setLeftBarButtonItems :[ NSArray arrayWithObjects :negativeSpacer, leftBarButtonItem, nil ]];
    } else {
        // Just set the UIBarButtonItem as you would normally
        [ self setLeftBarButtonItem :leftBarButtonItem];
    }
}
- (void)addRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
    if ( ios7 ) {
        // Add a spacer on when running lower than iOS 7.0
        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ]
                                           initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                           target : nil action : nil ];
        negativeSpacer. width = -5;
        [ self setRightBarButtonItems :[ NSArray arrayWithObjects :negativeSpacer, rightBarButtonItem, nil ]];
    } else {
        // Just set the UIBarButtonItem as you would normally
        [ self setRightBarButtonItem :rightBarButtonItem];
    }
}
@end
////在要设置返回按钮的UIViewController中按照如下使用。
////[ self . navigationItem addLeftBarButtonItem: [ self  creatBarItemWithAction : @selector (dismiss)]];
////creatBarItemWithAction是我自己写的一个方法。
//
///**
// *  退出视图。
// */
//-( void )dismiss
//{
//    [ self dismissViewControllerAnimated : YES completion : nil ];
//}
///**
// *  创建一个 UIBarButtonItem
// *
// *  @param _action action
// *
// *  @return UIBarButtonItem
// */
//-( UIBarButtonItem *)creatBarItemWithAction:( SEL )_action{
//    UIButton * button = [ UIButton buttonWithType : UIButtonTypeCustom ];
//    [button setImage :[ UIImage imageNamed : @"backButton.png" ] forState : UIControlStateNormal ];
//    [button setFrame : CGRectMake ( 0 , 0 , 40 , 40 )];
//    [button addTarget : self action :_action forControlEvents : UIControlEventTouchUpInside ];
//    UIBarButtonItem * item = [[ UIBarButtonItem alloc ] initWithCustomView :button] ;
//    return item;
//}
//方式二：在创建自定义 UIBarButtonItem 的时候通过设置自定义view的图片偏移属性来做适配。
//在要设置返回按钮的UIViewController中按照如下使用。
//
//self . navigationItem . leftBarButtonItem = [ self creatBarItemWithAction : @selector (dismiss) solutiontwo : 2 ];
//-( UIBarButtonItem *)creatBarItemWithAction:( SEL )_action solutiontwo:( NSInteger )index{
//    UIButton * button = [ UIButton buttonWithType : UIButtonTypeCustom ];
//    [button setImage :[ UIImage imageNamed : @"backButton.png" ] forState : UIControlStateNormal ];
//    [button setFrame : CGRectMake ( 0 , 0 , 40 , 40 )];
//    if ( ios7 ) {
//        [button  setImageEdgeInsets : UIEdgeInsetsMake ( 0 , - 30 , 0 , 0 )];
//    }
//    else
//    {
//        [button  setImageEdgeInsets : UIEdgeInsetsMake ( 0 , 0 , 0 , 0 )];
//    }
//    [button addTarget : self action :_action forControlEvents : UIControlEventTouchUpInside ];
//    UIBarButtonItem * item = [[ UIBarButtonItem alloc ] initWithCustomView :button] ;
//    return item;
//}
