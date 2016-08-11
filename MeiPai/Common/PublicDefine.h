//
//  PublicDefine.h
//  MeiPai
//
//  Created by xwmedia03 on 15/7/30.
//  Copyright (c) 2015年 zp. All rights reserved.
//

#ifndef MeiPai_PublicDefine_h
#define MeiPai_PublicDefine_h

//日志开关 仅在debug下会起作用
#ifdef DEBUG
#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#define LWLog(...)  printf("%s [line%d] --- \n",__func__,__LINE__);NSLog(__VA_ARGS__)
#else
#define LWLog(...)
#endif



//获取屏幕高度宽度的宏
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

//获取状态栏高度的宏
#define TOP_HEIGHT (20)

//获取导航栏高度的宏
#define NAV_HEIGHT (64)

#define TAB_HEIGHT (49)

#define IOS_8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IOS_9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

//CGRect CGSize CGPoint 的便利生成
#define Rect(X, Y, W, H) (CGRectMake((X), (Y), (W), (H)))
#define Size(W, H) (CGSizeMake((W), (H)))
#define Point(X, Y) (CGPointMake((X), (Y)))

//获取系统时间戳
#define getCurrentTime [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]

// iOS系统版本
#define SYSTEM_VERSION    [[[UIDevice currentDevice] systemVersion] doubleValue]

// 标准系统状态栏高度
#define SYS_STATUSBAR_HEIGHT                        20

// 热点栏高度
#define HOTSPOT_STATUSBAR_HEIGHT            20

// 导航栏（UINavigationController.UINavigationBar）高度
#define NAVIGATIONBAR_HEIGHT                44

// 工具栏（UINavigationController.UIToolbar）高度
#define TOOLBAR_HEIGHT                              44

// 标签栏（UITabBarController.UITabBar）高度
#define TABBAR_HEIGHT                              49

// APP_STATUSBAR_HEIGHT=SYS_STATUSBAR_HEIGHT+[HOTSPOT_STATUSBAR_HEIGHT]
#define APP_STATUSBAR_HEIGHT                (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))

// 根据APP_STATUSBAR_HEIGHT判断是否存在热点栏
#define IS_HOTSPOT_CONNECTED                (APP_STATUSBAR_HEIGHT==(SYS_STATUSBAR_HEIGHT+HOTSPOT_STATUSBAR_HEIGHT)?YES:NO)

// 无热点栏时，标准系统状态栏高度+导航栏高度
#define NORMAL_STATUS_AND_NAV_BAR_HEIGHT    (SYS_STATUSBAR_HEIGHT+NAVIGATIONBAR_HEIGHT)

// 实时系统状态栏高度+导航栏高度，如有热点栏，其高度包含在APP_STATUSBAR_HEIGHT中。
#define STATUS_AND_NAV_BAR_HEIGHT                    (20+NAVIGATIONBAR_HEIGHT)

// 取到keyWindow
#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#define LOCALMANGERFILEPATH  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"LocalManager.plist"]

#define PINKCOLOR  RGB(229, 61, 146) 

//  判断是神马机子
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.width == 320) ? YES : NO)

#define IS_IPhone6 (667 == [[UIScreen mainScreen] bounds].size.height ? YES : NO)

#define IS_IPhone6plus (736 == [[UIScreen mainScreen] bounds].size.height ? YES : NO)



#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//RGB 数值设置颜色
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


//录制视频片段存储文件夹
#define ClipsDictionaryPath     [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Clips"]
#define MergeDictionaryPath     [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Merge"]

#define MB_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;

#endif
