//
//  MPVideoClipCoverView.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/12.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPVideoClipControl.h"
#import "MPVideFramePreViewCell.h"

static NSString *FRAMEPREVIEWCELLIDENTITIFER = @"FRAMEPREVIEWCELLIDENTITIFER";

@interface MPVideoClipControl()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>



@property (nonatomic, strong) UIView *leftCoverView;
@property (nonatomic, strong) UIView *centerCoverView;
@property (nonatomic, strong) UIView *rightCoverView;

@property (nonatomic, strong) UIButton *leftCursorButton;

@property (nonatomic, strong) UIButton *rightCursorButton;


@end

@implementation MPVideoClipControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.framePreviewsArray = [[NSMutableArray alloc] init];
        [self.framePreviewsCollectionView reloadData];
        
        _leftCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CoverHeight)];
        _leftCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _leftCoverView.userInteractionEnabled = NO;
        [self addSubview:_leftCoverView];
        
        
        _centerCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CoverHeight)];
        _centerCoverView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _centerCoverView.layer.borderWidth = 1;
        _centerCoverView.userInteractionEnabled = NO;
        [self addSubview:_centerCoverView];
        
        _rightCoverView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, 0, CoverHeight)];
        _rightCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _rightCoverView.userInteractionEnabled = NO;
        [self addSubview:_rightCoverView];
        
        
        UIImage *imageCursor = [UIImage imageNamed:@"ClipCursor"];
   
        
        CGFloat cursorWidth = imageCursor.size.width + 10;
        CGFloat cursorHeight = imageCursor.size.height;
        
        _leftCursorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftCursorButton.frame = CGRectMake(0, 0, cursorWidth, cursorHeight);
        [_leftCursorButton setExclusiveTouch:YES];
        [_leftCursorButton setImage:imageCursor forState:UIControlStateNormal];
        [_leftCursorButton addTarget:self action:@selector(cursorButtonDragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
//        [_leftCursorButton addTarget:self action:@selector(cursorButtonDragEnded:withEvent: )forControlEvents: UIControlEventTouchUpInside |
//         UIControlEventTouchUpOutside];
        _leftCursorButton.adjustsImageWhenHighlighted = NO;
        [self addSubview:_leftCursorButton];
        
        _rightCursorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightCursorButton.frame = CGRectMake(SCREEN_WIDTH-cursorWidth, 0, cursorWidth, cursorHeight);
        [_rightCursorButton setImage:imageCursor forState:UIControlStateNormal];
        [_rightCursorButton addTarget:self action:@selector(cursorButtonDragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
//        [_rightCursorButton addTarget:self action:@selector(cursorButtonDragEnded:withEvent: )forControlEvents: UIControlEventTouchUpInside |
//         UIControlEventTouchUpOutside];
        [_rightCursorButton setExclusiveTouch:YES];
        _rightCursorButton.adjustsImageWhenHighlighted = NO;
        [self addSubview:_rightCursorButton];
        
        _leftCursorButton.centerX = 0;
        _rightCursorButton.centerX = SCREEN_WIDTH;
        
     
    }
    return self;
}


/**
 *  加载 tableView 视图
 */
- (UICollectionView *)framePreviewsCollectionView{
    if (!_framePreviewsCollectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(FramePreviewItemSize, FramePreviewItemSize);
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _framePreviewsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FramePreviewItemSize) collectionViewLayout:layout];
        [self addSubview:_framePreviewsCollectionView];
        _framePreviewsCollectionView.alwaysBounceVertical = YES;
        _framePreviewsCollectionView.bounces = NO;
        _framePreviewsCollectionView.showsHorizontalScrollIndicator = NO;
        _framePreviewsCollectionView.showsVerticalScrollIndicator = NO;
        _framePreviewsCollectionView.showsVerticalScrollIndicator = NO;
        _framePreviewsCollectionView.backgroundColor = [UIColor clearColor];
        
        _framePreviewsCollectionView.delegate = self;
        _framePreviewsCollectionView.dataSource = self;
        
        
        //  注册重用池
        [_framePreviewsCollectionView registerClass:[MPVideFramePreViewCell class] forCellWithReuseIdentifier:FRAMEPREVIEWCELLIDENTITIFER];
        [_framePreviewsCollectionView setExclusiveTouch:YES];
        
    }
    return _framePreviewsCollectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.framePreviewsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPVideFramePreViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FRAMEPREVIEWCELLIDENTITIFER forIndexPath:indexPath];
    cell.image = self.framePreviewsArray[indexPath.row];
    return cell;
}


//
- (CGFloat)value
{
    
    CGFloat collectionViewWidth = self.framePreviewsCollectionView.contentSize.width;
    if (self.leftCursorButton.isTouchInside) {
        return self.leftCursorButton.centerX/collectionViewWidth;
    }
    else  if (self.rightCursorButton.isTouchInside) {
        return self.rightCursorButton.centerX/collectionViewWidth;
    }
    else  if (self.framePreviewsCollectionView.isDragging) {
        CGFloat OffsetX = self.framePreviewsCollectionView.contentOffset.x;
        return (OffsetX+self.leftCursorButton.centerX)/collectionViewWidth;
    }
    return 0;
    
}

- (void)cursorButtonDragMoving:(UIButton *)sender withEvent:(UIEvent *)event
{
    [self moveToNewPointWithSender:sender withEvent:event];
}

- (void)cursorButtonDragEnded:(UIButton *)sender withEvent:(UIEvent *)event
{
//    [self moveToNewPointWithSender:sender withEvent:event];
}


- (void)moveToNewPointWithSender:(UIButton *)sender withEvent:(UIEvent *)event
{
    CGPoint newPoint = [[[event allTouches] anyObject] locationInView:self];
    CGFloat newCenterX = newPoint.x;
    

    if (sender == self.leftCursorButton)
    {
        
        self.leftCoverView.width = newCenterX;
        sender.centerX = newCenterX;
        
  
        
//        //判断是否可以继续拖动
//        if ((_rightCursorButton.centerX-_leftCursorButton.centerX) >= 100) {
//            self.leftCoverView.width = newCenterX;
//            sender.centerX = newCenterX;
//            
//            
//            
//        }
//        else
//        {
//            newCenterX = SCREEN_WIDTH-_rightCoverView.width-100;
//            self.leftCoverView.width = newCenterX;
//            sender.centerX = newCenterX;
//        }
        
    }
    else
    {
//        //判断是否可以继续拖动
//        if ((_rightCursorButton.centerX-_leftCursorButton.centerX) <= 100) {
//            if ((newCenterX-sender.centerX)<0) {
//                return;
//            }
//        }
//        
        CGFloat newWidth = SCREEN_WIDTH-newCenterX;
        self.rightCoverView.frame = CGRectMake(SCREEN_WIDTH-newWidth, 0, newWidth, CoverHeight);
        sender.centerX = newCenterX;
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    self.centerCoverView.frame = CGRectMake(self.leftCursorButton.centerX, 0, self.rightCursorButton.centerX-self.leftCursorButton.centerX, CoverHeight);
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end


