//
//  MPVideFramePreViewCell.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/12.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPVideFramePreViewCell.h"
#import "UIImage+Antialiase.h"
@implementation MPVideFramePreViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = [UIImage scaleToSize:_imageView.bounds.size cut:SaveCenter image:image];
}

@end
