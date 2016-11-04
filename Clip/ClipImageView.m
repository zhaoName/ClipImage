//
//  ClipImageView.m
//  ClipImage
//
//  Created by zhao on 16/11/1.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "ClipImageView.h"
#import "ClipAreaView.h"
#import "MidLineView.h"

#define CORNER_WIDTH 16

@interface ClipImageView ()

@property (nonatomic, strong) UIImageView *clipImageView;
@property (nonatomic, strong) ClipAreaView *clipAreaView;
@property (nonatomic, assign) CGFloat clipViewX; /**< 裁剪区域的X*/
@property (nonatomic, assign) CGFloat clipViewY; /**< 裁剪区域的Y*/

// 四个拐角
@property (nonatomic, strong) UIImageView *topLeftImageView;
@property (nonatomic, strong) UIImageView *topRightImageView;
@property (nonatomic, strong) UIImageView *bottomLeftImageView;
@property (nonatomic, strong) UIImageView *bottomRightImageView;
// 拐角的手势
@property (nonatomic, strong) UIPanGestureRecognizer *topLeftPan;
@property (nonatomic, strong) UIPanGestureRecognizer *topRightPan;
@property (nonatomic, strong) UIPanGestureRecognizer *bottomLeftPan;
@property (nonatomic, strong) UIPanGestureRecognizer *bottomRightPan;
// 四个拐角的坐标
@property (nonatomic, assign) CGPoint topLeftPoint;
@property (nonatomic, assign) CGPoint topRightPoint;
@property (nonatomic, assign) CGPoint bottomLeftPoint;
@property (nonatomic, assign) CGPoint bottomRightPoint;
//四条中间线
@property (nonatomic, strong) MidLineView *topMidLine;
@property (nonatomic, strong) MidLineView *leftMidLine;
@property (nonatomic, strong) MidLineView *bottomMidLine;
@property (nonatomic, strong) MidLineView *rightMidLine;


@end

@implementation ClipImageView

#pragma mark -- 初始化

+ (instancetype)initWithFrame:(CGRect)frame
{
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if([super initWithFrame:frame])
    {
        self.clipViewX = (MAX(CLIP_WIDTH, CLIP_HEIGHT) - MIN(CLIP_WIDTH, CLIP_HEIGHT)) / 2.0;
        self.clipViewY = self.clipViewX;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if([super initWithCoder:aDecoder])
    {
        self.clipViewX = (MAX(CLIP_WIDTH, CLIP_HEIGHT) - MIN(CLIP_WIDTH, CLIP_HEIGHT)) / 2.0;
        self.clipViewY = self.clipViewX;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.clipAreaView addObserver:self forKeyPath:@"clipView.frame" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.clipAreaView addObserver:self forKeyPath:@"clipView.center" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    [self addSubview:self.clipImageView];
    [self addSubview:self.clipAreaView];
    // 设置裁剪区域的四个拐角
    [self setupCornerImageView];
    // 根据四个拐角的位置确定裁剪区域(透明区域)
    [self resetClipViewFrameWhenCornerFrameSure];
    // 创建中间线
    [self setupMidLine];
}

#pragma mark -- KVO

// KVO监测裁剪区域frame或center的改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 随着长按手势的移动，改变裁剪区域的frame
    [self.clipAreaView resetClipViewFrame];
    // 随着裁剪区域的移动，改变四个拐角图片的位置
    [self resetCornerViewFrameWhenClipViewMoving];
    // 随着裁剪区域的移动，改变中间线的位置
    [self resetMidLineViewFrameWhenClipViewMoving];
}

#pragma mark -- 裁剪区域

/**
 *  根据四个拐角的位置 重新确定裁剪区域(透明区域)
 */
- (void)resetClipViewFrameWhenCornerFrameSure
{
    self.clipAreaView.clipView.frame = CGRectMake(self.topLeftImageView.frame.origin.x, self.topLeftImageView.frame.origin.y, CGRectGetMaxX(self.topRightImageView.frame) - CGRectGetMinX(self.topLeftImageView.frame), CGRectGetMaxY(self.bottomLeftImageView.frame) - CGRectGetMinY(self.topLeftImageView.frame));
}

#pragma mark -- 四个拐角
/**
 *  设置裁剪区域的四个拐角的图片 添加手势
 */
- (void)setupCornerImageView
{
    // 刚出现的裁剪区域是一个正方形
    if(CLIP_WIDTH >= CLIP_HEIGHT)
    {
        self.topLeftImageView.frame = CGRectMake(self.clipViewX, 0, CORNER_WIDTH, CORNER_WIDTH);
        self.topRightImageView.frame = CGRectMake(CLIP_WIDTH - self.clipViewX - CORNER_WIDTH, 0, CORNER_WIDTH, CORNER_WIDTH);
        self.bottomLeftImageView.frame = CGRectMake(self.clipViewX, CLIP_HEIGHT - CORNER_WIDTH, CORNER_WIDTH, CORNER_WIDTH);
        self.bottomRightImageView.frame = CGRectMake(CLIP_WIDTH - self.clipViewX - CORNER_WIDTH, CLIP_HEIGHT - CORNER_WIDTH, CORNER_WIDTH, CORNER_WIDTH);
    }
    else
    {
        self.topLeftImageView.frame = CGRectMake(0, self.clipViewY, CORNER_WIDTH, CORNER_WIDTH);
        self.topRightImageView.frame = CGRectMake(CLIP_WIDTH - CORNER_WIDTH, self.clipViewY, CORNER_WIDTH, CORNER_WIDTH);
        self.bottomLeftImageView.frame = CGRectMake(0, CLIP_HEIGHT-self.clipViewX-CORNER_WIDTH, CORNER_WIDTH, CORNER_WIDTH);
        self.bottomRightImageView.frame = CGRectMake(CLIP_WIDTH - CORNER_WIDTH, CLIP_HEIGHT-self.clipViewX-CORNER_WIDTH, CORNER_WIDTH, CORNER_WIDTH);
    }
    [self addSubview:self.topLeftImageView];
    [self addSubview:self.topRightImageView];
    [self addSubview:self.bottomLeftImageView];
    [self addSubview:self.bottomRightImageView];
    // 添加长按手势
    [self.topLeftImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCornerPan:)]];
    [self.topRightImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCornerPan:)]];
    [self.bottomLeftImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCornerPan:)]];
    [self.bottomRightImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCornerPan:)]];
}

/**
 *  处理拐角的长安手势，使裁剪区域能够随着某个corner的移动而变化
 */
- (void)handleCornerPan:(UIPanGestureRecognizer *)panGesture
{
    // 响应的imageView
    UIImageView *imageView = (UIImageView *)panGesture.view;
    // 移动的坐标
    CGPoint movePoint = [panGesture translationInView:self];
    
    if(panGesture.state == UIGestureRecognizerStateBegan)
    {
        // 裁剪区域四个拐角的坐标
        self.topLeftPoint = self.clipAreaView.clipView.frame.origin;
        self.topRightPoint = CGPointMake(CGRectGetMaxX(self.clipAreaView.clipView.frame), CGRectGetMinY(self.clipAreaView.clipView.frame));
        self.bottomLeftPoint = CGPointMake(CGRectGetMinX(self.clipAreaView.clipView.frame), CGRectGetMaxY(self.clipAreaView.clipView.frame));
        self.bottomRightPoint = CGPointMake(CGRectGetMaxX(self.clipAreaView.clipView.frame), CGRectGetMaxY(self.clipAreaView.clipView.frame));
    }
    else if(panGesture.state == UIGestureRecognizerStateChanged)
    {
        // 长按不同corner，改变裁剪区域的frame，从而通过KVO改变Corner的frame
        if([imageView isEqual:self.topLeftImageView])
        {
            // 将要移动到的位置
            CGPoint willPoint = CGPointMake(self.topLeftPoint.x + movePoint.x, self.topLeftPoint.y + movePoint.y);
            // 实际能能到达的范围
            CGPoint actualPoint = CGPointMake(MIN(MAX(0, willPoint.x), CGRectGetMinX(self.topRightImageView.frame) - CORNER_WIDTH - MID_LINE_WIDTH), MIN(MAX(0, willPoint.y), CGRectGetMinY(self.bottomLeftImageView.frame) - CORNER_WIDTH - MID_LINE_WIDTH));
            // 确定变化后的frame
            self.clipAreaView.clipView.frame = CGRectMake(actualPoint.x, actualPoint.y, CGRectGetMaxX(self.topRightImageView.frame) - actualPoint.x, CGRectGetMaxY(self.bottomLeftImageView.frame) - actualPoint.y);
        }
        else if([imageView isEqual:self.topRightImageView])
        {
            CGPoint willPoint = CGPointMake(self.topRightPoint.x + movePoint.x, self.topRightPoint.y + movePoint.y);
            
            CGPoint actualPoint = CGPointMake(MIN(MAX(self.topLeftPoint.x + CORNER_WIDTH*2 + MID_LINE_WIDTH, willPoint.x), CLIP_WIDTH), MIN(MAX(0, willPoint.y), CGRectGetMaxY(self.bottomLeftImageView.frame) - CORNER_WIDTH*2 - MID_LINE_WIDTH));
            
            self.clipAreaView.clipView.frame = CGRectMake(self.topLeftPoint.x, actualPoint.y, actualPoint.x - self.topLeftPoint.x, CGRectGetMaxY(self.bottomLeftImageView.frame) - actualPoint.y);
        }
        else if([imageView isEqual:self.bottomLeftImageView])
        {
            CGPoint willPoint = CGPointMake(self.bottomLeftPoint.x + movePoint.x, self.bottomLeftPoint.y + movePoint.y);
            
            CGPoint actualPoint = CGPointMake(MIN(MAX(0, willPoint.x), CGRectGetMaxX(self.topRightImageView.frame) - CORNER_WIDTH*2 - MID_LINE_WIDTH), MIN(MAX(self.topLeftPoint.y + CORNER_WIDTH*2 + MID_LINE_WIDTH, willPoint.y), CLIP_HEIGHT));
            
            self.clipAreaView.clipView.frame = CGRectMake(actualPoint.x, self.topLeftPoint.y, CGRectGetMaxX(self.topRightImageView.frame) - actualPoint.x, actualPoint.y - self.topLeftPoint.y);
        }
        else
        {
            CGPoint willPoint = CGPointMake(self.bottomRightPoint.x + movePoint.x, self.bottomRightPoint.y + movePoint.y);
            
            CGPoint actualPoint = CGPointMake(MIN(MAX(self.topLeftPoint.x + CORNER_WIDTH*2 + MID_LINE_WIDTH, willPoint.x), CLIP_WIDTH), MIN(MAX(self.topLeftPoint.y + CORNER_WIDTH*2 + MID_LINE_WIDTH, willPoint.y), CLIP_HEIGHT));
            
            self.clipAreaView.clipView.frame = CGRectMake(self.topLeftPoint.x, self.topLeftPoint.y, actualPoint.x - self.topLeftPoint.x, actualPoint.y - self.topLeftPoint.y);
        }
    }
}

/**
 *  随着裁剪区域的移动，改变四个拐角图片的位置
 */
- (void)resetCornerViewFrameWhenClipViewMoving
{
    self.topLeftImageView.frame = CGRectMake(CGRectGetMinX(self.clipAreaView.clipView.frame), CGRectGetMinY(self.clipAreaView.clipView.frame), CORNER_WIDTH, CORNER_WIDTH);
    self.topRightImageView.frame = CGRectMake(CGRectGetMaxX(self.clipAreaView.clipView.frame) - CORNER_WIDTH, CGRectGetMinY(self.clipAreaView.clipView.frame), CORNER_WIDTH, CORNER_WIDTH);
    self.bottomLeftImageView.frame = CGRectMake(CGRectGetMinX(self.clipAreaView.clipView.frame), CGRectGetMaxY(self.clipAreaView.clipView.frame) - CORNER_WIDTH, CORNER_WIDTH, CORNER_WIDTH);
    self.bottomRightImageView.frame = CGRectMake(CGRectGetMaxX(self.clipAreaView.clipView.frame) - CORNER_WIDTH, CGRectGetMaxY(self.clipAreaView.clipView.frame) - CORNER_WIDTH, CORNER_WIDTH, CORNER_WIDTH);
}

#pragma mark -- 中间长按手势线

/**
 *  创建中间长按手势线
 */
- (void)setupMidLine
{
    [self addSubview:self.topMidLine];
    [self addSubview:self.leftMidLine];
    [self addSubview:self.bottomMidLine];
    [self addSubview:self.rightMidLine];
}

- (void)handleMidLinePan:(UIPanGestureRecognizer *)panGesture
{
    MidLineView *midLine = (MidLineView *)panGesture.view;
    CGPoint movePoint = [panGesture translationInView:self];
    
    if(panGesture.state == UIGestureRecognizerStateBegan)
    {
        self.topLeftPoint = self.clipAreaView.clipView.frame.origin;
        self.bottomRightPoint = CGPointMake(CGRectGetMaxX(self.clipAreaView.clipView.frame), CGRectGetMaxY(self.clipAreaView.clipView.frame));
    }
    else if(panGesture.state == UIGestureRecognizerStateChanged)
    {
        switch (midLine.midLineType)
        {
            case MidLineViewTypeTop:
            {
                CGFloat actualY = MIN(MAX(0, self.topLeftPoint.y + movePoint.y), CGRectGetMaxY(self.clipAreaView.clipView.frame) - CORNER_WIDTH*2 - MID_LINE_WIDTH);
                self.clipAreaView.clipView.frame = CGRectMake(self.topLeftPoint.x, actualY, CGRectGetWidth(self.clipAreaView.clipView.frame), CGRectGetMaxY(self.clipAreaView.clipView.frame) - actualY);
                break;
            }
            case MidLineViewTypeLeft:
            {
                CGFloat actualX = MIN(MAX(0, self.topLeftPoint.x + movePoint.x), CGRectGetMaxX(self.clipAreaView.clipView.frame) - CORNER_WIDTH*2 - MID_LINE_WIDTH);
                self.clipAreaView.clipView.frame = CGRectMake(actualX, self.topLeftPoint.y, CGRectGetMaxX(self.clipAreaView.clipView.frame) - actualX, CGRectGetHeight(self.clipAreaView.clipView.frame));
                break;
            }
            case MidLineViewTypeBottom:
            {
                CGFloat actualY = MIN(MAX(self.topLeftPoint.y + CORNER_WIDTH*2 + MID_LINE_WIDTH, self.bottomRightPoint.y + movePoint.y), CLIP_HEIGHT);
                self.clipAreaView.clipView.frame = CGRectMake(self.topLeftPoint.x, self.topLeftPoint.y, CGRectGetWidth(self.clipAreaView.clipView.frame), actualY - self.topLeftPoint.y);
                break;
            }
            case MidLineViewTypeRight:
            {
                CGFloat actualX = MIN(MAX(self.topLeftPoint.x + CORNER_WIDTH*2 + MID_LINE_WIDTH, self.bottomRightPoint.x + movePoint.x), CLIP_WIDTH);
                self.clipAreaView.clipView.frame = CGRectMake(self.topLeftPoint.x, self.topLeftPoint.y,actualX - self.topLeftPoint.x, CGRectGetHeight(self.clipAreaView.clipView.frame));
                break;
            }
        }
    }
}

/**
 *  重置中间线的位置
 */
- (void)resetMidLineViewFrameWhenClipViewMoving
{
    self.topMidLine.center = CGPointMake(CGRectGetMidX(self.clipAreaView.clipView.frame), CGRectGetMinY(self.clipAreaView.clipView.frame));
    self.leftMidLine.center = CGPointMake(CGRectGetMinX(self.clipAreaView.clipView.frame), CGRectGetMidY(self.clipAreaView.clipView.frame));
    self.bottomMidLine.center = CGPointMake(CGRectGetMidX(self.clipAreaView.clipView.frame), CGRectGetMaxY(self.clipAreaView.clipView.frame));
    self.rightMidLine.center = CGPointMake(CGRectGetMaxX(self.clipAreaView.clipView.frame), CGRectGetMidY(self.clipAreaView.clipView.frame));
}

#pragma mark -- 裁剪

- (UIImage *)getClipedImage
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.clipImage.CGImage, self.clipAreaView.clipView.frame);
    UIImage* subImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    NSLog(@"裁剪%@", NSStringFromCGRect(self.clipAreaView.clipView.frame));
    return subImage;
}

- (void)dealloc
{
    [self.clipAreaView removeObserver:self forKeyPath:@"clipView.frame"];
    [self.clipAreaView removeObserver:self forKeyPath:@"clipView.center"];
}

#pragma mark -- getter/setter

- (UIImageView *)clipImageView
{
    if(!_clipImageView)
    {
        _clipImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _clipImageView.image = self.clipImage;
    }
    return _clipImageView;
}

- (ClipAreaView *)clipAreaView
{
    if(!_clipAreaView)
    {
        _clipAreaView = [[ClipAreaView alloc] initWithFrame:self.bounds];
    }
    return _clipAreaView;
}

- (UIImageView *)topLeftImageView
{
    if(!_topLeftImageView)
    {
        _topLeftImageView = [[UIImageView alloc] init];
        _topLeftImageView.userInteractionEnabled = YES;
        _topLeftImageView.image = [UIImage imageNamed:@"arrow1"];
    }
    return _topLeftImageView;
}

- (UIImageView *)topRightImageView
{
    if(!_topRightImageView)
    {
        _topRightImageView = [[UIImageView alloc] init];
        _topRightImageView.userInteractionEnabled = YES;
        _topRightImageView.image = [UIImage imageNamed:@"arrow2"];
    }
    return _topRightImageView;
}

- (UIImageView *)bottomLeftImageView
{
    if(!_bottomLeftImageView)
    {
        _bottomLeftImageView = [[UIImageView alloc] init];
        _bottomLeftImageView.userInteractionEnabled = YES;
        _bottomLeftImageView.image = [UIImage imageNamed:@"arrow3"];
    }
    return _bottomLeftImageView;
}

- (UIImageView *)bottomRightImageView
{
    if(!_bottomRightImageView)
    {
        _bottomRightImageView = [[UIImageView alloc] init];
        _bottomRightImageView.userInteractionEnabled = YES;
        _bottomRightImageView.image = [UIImage imageNamed:@"arrow4"];
    }
    return _bottomRightImageView;
}

- (MidLineView *)topMidLine
{
    if(!_topMidLine)
    {
        _topMidLine = [[MidLineView alloc] initWithWidth:MID_LINE_WIDTH height:MID_LINE_INVISIBLE type:MidLineViewTypeTop];
        _topMidLine.midLineColor = self.midLineColor;
        [_topMidLine addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMidLinePan:)]];
    }
    return _topMidLine;
}

- (MidLineView *)leftMidLine
{
    if(!_leftMidLine)
    {
        _leftMidLine = [[MidLineView alloc] initWithWidth:MID_LINE_INVISIBLE height:MID_LINE_WIDTH type:MidLineViewTypeLeft];
        _leftMidLine.midLineColor = self.midLineColor;
        
        [_leftMidLine addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMidLinePan:)]];
    }
    return _leftMidLine;
}

- (MidLineView *)bottomMidLine
{
    if(!_bottomMidLine)
    {
        
        _bottomMidLine = [[MidLineView alloc] initWithWidth:MID_LINE_WIDTH height:MID_LINE_INVISIBLE type:MidLineViewTypeBottom];
        _bottomMidLine.midLineColor = self.midLineColor;
        
        [_bottomMidLine addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMidLinePan:)]];
    }
    return _bottomMidLine;
}

- (MidLineView *)rightMidLine
{
    if(!_rightMidLine)
    {
        _rightMidLine = [[MidLineView alloc] initWithWidth:MID_LINE_INVISIBLE height:MID_LINE_WIDTH type:MidLineViewTypeRight];
        _rightMidLine.midLineColor = self.midLineColor;
        
        [_rightMidLine addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMidLinePan:)]];
    }
    return _rightMidLine;
}

@end
