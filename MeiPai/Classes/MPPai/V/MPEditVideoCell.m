//
//  MPEditVideoCell.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/15.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPEditVideoCell.h"

@implementation MPEditVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _iconImageView.layer.cornerRadius = 30;
        [self addSubview:_iconImageView];
        
        _iconPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconImageView.frame)+8, CGRectGetMaxX(_iconImageView.bounds), 15)];
        _iconPromptLabel.textAlignment = 1;
        _iconPromptLabel.font = [UIFont systemFontOfSize:11];
        _iconPromptLabel.textColor = [UIColor whiteColor];
        [self addSubview:_iconPromptLabel];
        
    }
    return self;
}


- (void)setDatasource:(NSDictionary *)datasource
{
    _datasource = datasource;
    
    NSString *imageName = datasource[@"imageName"];
    NSString *title = datasource[@"title"];
    _iconImageView.image = [UIImage imageNamed:imageName];
    _iconPromptLabel.text = title;
}

@end
