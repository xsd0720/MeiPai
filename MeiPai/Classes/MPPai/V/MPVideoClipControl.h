//
//  MPVideoClipCoverView.h
//  MeiPai
//
//  Created by xwmedia01 on 16/8/12.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MPVideoClipCoverViewHeight  70.0f
#define CoverHeight  40
#define FramePreviewItemSize  40
@interface MPVideoClipControl : UIControl

@property (strong, nonatomic) NSMutableArray *framePreviewsArray;

@property (strong, nonatomic) UICollectionView *framePreviewsCollectionView;

@property (nonatomic, assign) CGFloat value;


@end
