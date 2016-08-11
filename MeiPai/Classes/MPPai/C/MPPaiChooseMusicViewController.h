//
//  MPPaiChooseMusicViewController.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/11.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChooseMusicBlock)(NSString *fileName);

@interface MPPaiChooseMusicViewController : UIViewController

@property (nonatomic) ChooseMusicBlock chooseMusicBlock;

@end
