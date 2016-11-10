//
//  ClipAreaView.m
//  ClipImage
//
//  Created by zhao on 16/11/1.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  裁剪区域

#import "ClipAreaView.h"

@interface ClipAreaView ()

@property (nonatomic, strong) UIPanGestureRecognizer *clipViewPan;
@property (nonatomic, assign) CGPoint originCenter;

@end

@implementation ClipAreaView

#pragma mark -- 初始化

+ (instancetype)initWithFrame:(CGRect)frame
{
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if([super initWithFrame:frame])
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        self.clipAreaType = ClipAreaViewTypeRect;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 创建裁剪区域 矩形
    if(self.clipAreaType == ClipAreaViewTypeRect)
    {
       [self setupClipView];
    }
    else
    {
        [self addSubview:self.clipView];
        [self resetClipViewFrame];
    }
}

/**
 *  添加点击手势
 */
- (void)setupClipView
{
    [self addSubview:self.clipView];
    self.clipViewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCropAreaPan:)];
    [self.clipView addGestureRecognizer:self.clipViewPan];
}

/**
 *  处理点击手势 重置裁剪区域
 */
- (void)handleCropAreaPan:(UIPanGestureRecognizer *)panGesture
{
    if(panGesture.state == UIGestureRecognizerStateBegan)
    {
        self.originCenter = self.clipView.center;
    }
    else if(panGesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGesture translationInView:self];
        // 将要移动到的位置
        CGPoint willCenter = CGPointMake(self.originCenter.x + translation.x, self.originCenter.y + translation.y);
        // X方向上最小和最大的移动范围
        CGFloat minCenterX = self.clipView.frame.size.width / 2.0;
        CGFloat maxCenterX = CLIP_WIDTH - self.clipView.frame.size.width / 2.0;
        // Y方向上最小和最大的移动范围
        CGFloat minCenterY = self.clipView.frame.size.height / 2.0;
        CGFloat maxCenterY = CLIP_HEIGHT - self.clipView.frame.size.height / 2.0;
        // 随着手指的移动，重置裁剪区域的位置
        self.clipView.center = CGPointMake(MIN(MAX(willCenter.x, minCenterX), maxCenterX), MIN(MAX(willCenter.y, minCenterY), maxCenterY));
    }
}

/**
 *  随着裁剪区域的改变 重置不透明区域，即不裁剪的部分
 */
- (void)resetClipViewFrame
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *clearPath = nil;
    // 矩形
    if(self.clipAreaType == ClipAreaViewTypeRect){
        clearPath = [[UIBezierPath bezierPathWithRect:self.clipView.frame] bezierPathByReversingPath];
    }
    else {// 圆形
        clearPath = [[UIBezierPath bezierPathWithOvalInRect:self.clipView.frame] bezierPathByReversingPath];
    }
    [path appendPath:clearPath];
    CAShapeLayer *shareLayer = (CAShapeLayer *)self.layer.mask;
    if(!shareLayer)
    {
        shareLayer = [CAShapeLayer layer];
        [self.layer setMask:shareLayer];
    }
    shareLayer.path = path.CGPath;
}

- (void)dealloc
{
    [self.clipView removeGestureRecognizer:self.clipViewPan];
}

#pragma mark -- getter/setter

- (UIView *)clipView
{
    if(!_clipView)
    {
        _clipView = [[UIView alloc] initWithFrame:CGRectZero];
        _clipView.backgroundColor = [UIColor clearColor];
    }
    return _clipView;
}



@end
