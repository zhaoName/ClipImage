//
//  ClipImageView.m
//  ClipImage
//
//  Created by zhao on 16/11/1.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  图片裁剪的事件处理、交互

#import "ClipImageView.h"
#import "MidLineView.h"

#define CORNER_WIDTH 16
#define CLIP_ARC_DIAMETER 240

@interface ClipImageView ()

@property (nonatomic, strong) UIImageView *clipImageView; /**< 被裁剪的图片*/
@property (nonatomic, strong) ClipAreaView *clipAreaView; /**< 裁剪区域*/
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

@property (nonatomic, assign) CGFloat lastDistance; /**< 先前两个手指的距离*/
@property (nonatomic, assign) CGPoint imageStartMoveCenter; /**< 开始移动手指时图片的center*/
@property (nonatomic, assign) CGPoint startTouchPoint; /**< 开始移动手指point*/

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
    [self addSubview:self.clipImageView];
    [self addSubview:self.clipAreaView];
    
    if(self.clipType == ClipAreaViewTypeRect)
    {
        [self.clipAreaView addObserver:self forKeyPath:@"clipView.frame" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        [self.clipAreaView addObserver:self forKeyPath:@"clipView.center" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        // 设置裁剪区域的四个拐角
        [self setupCornerImageView];
        // 根据四个拐角的位置确定裁剪区域(透明区域)
        [self resetClipViewFrameWhenCornerFrameSure];
        // 创建中间线
        [self setupMidLine];
    }
    else
    {
        // 圆形裁剪区域最大直径240
        CGFloat w =  MIN(CLIP_WIDTH, CLIP_HEIGHT) < CLIP_ARC_DIAMETER ?:CLIP_ARC_DIAMETER;
        CGFloat x = (CLIP_WIDTH - w) / 2;
        CGFloat y = (CLIP_HEIGHT - w) / 2;
        self.clipAreaView.clipView.frame = CGRectMake(x, y, w, w);
    }
}

#pragma mark -- KVO

// KVO监测裁剪区域frame或center的改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 随着点击手势的移动，改变裁剪区域的frame
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
}

/**
 *  处理拐角的点击手势，使裁剪区域能够随着某个corner的移动而变化
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
        // 点击不同corner，改变裁剪区域的frame，从而通过KVO改变Corner的frame
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

#pragma mark -- 中间点击手势线

/**
 *  创建中间点击手势线
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

#pragma mark -- 缩放裁剪区域

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouchs = [event allTouches];
    if(allTouchs.count == 1 && self.clipType == ClipAreaViewTypeArc) // 一个手指移动图片
    {
        self.imageStartMoveCenter = self.clipImageView.center;
        self.startTouchPoint = [[touches anyObject] locationInView:self];
    }
}

// 移动手指
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouchs = [event allTouches];
    if(allTouchs.count == 1 && self.clipType == ClipAreaViewTypeArc) // 一个手指移动图片
    {
        CGPoint movePoint = [[touches anyObject] locationInView:self];
        // 手指移动的距离
        CGFloat x = movePoint.x - self.startTouchPoint.x;
        CGFloat y = movePoint.y - self.startTouchPoint.y;
        
        CGPoint willMoveToPoint = CGPointMake(self.imageStartMoveCenter.x + x, self.imageStartMoveCenter.y + y);
        self.clipImageView.center = willMoveToPoint;
    }
    else if(allTouchs.count == 2) // 两个手指缩放
    {
        if(self.clipType == ClipAreaViewTypeRect)
        {
            [self scaleClipView:self.clipAreaView.clipView withTouches:[allTouchs allObjects]];
        }
        else
        {
            [self scaleClipView:self.clipImageView withTouches:[allTouchs allObjects]];
        }
    }
}

// 手指移动结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.clipType == ClipAreaViewTypeArc)
    {
        [self correctClipImageViewFrame];
    }
}

/**
 *  根据两个手指的变化，缩放裁剪区域 或缩放被裁剪的图片
 */
- (void)scaleClipView:(UIView *)view withTouches:(NSArray *)touches
{
    CGPoint touch1 = [touches[0] locationInView:self];
    CGPoint touch2 = [touches[1] locationInView:self];
    
    // 计算两个手指的距离
    CGFloat distance = sqrtf((touch1.x - touch2.x)*(touch1.x - touch2.x) + (touch1.y - touch2.y)*(touch1.y - touch2.y));
    // 缩放裁剪区域，宽高最小为100
    CGRect viewFrame = view.frame;
    
    // 两指距离增加 即裁剪区域或图片放大
    if(distance > self.lastDistance + 1)
    {
        viewFrame.size.width += 8;
        self.lastDistance = distance;
    }
    // 两指距离缩小 即裁剪区域或图片缩小
    else if(distance < self.lastDistance - 1)
    {
        viewFrame.size.width -= 8;
        self.lastDistance = distance;
    }
    // 等比例缩放 换算出高度要变化的距离
    viewFrame.size.height = viewFrame.size.width * CGRectGetHeight(view.frame) / CGRectGetWidth(view.frame);
    
    // 算出x，y变化的距离
    CGFloat scaleX = (viewFrame.size.width - CGRectGetWidth(view.frame)) / 2.0;
    CGFloat scaleY = (viewFrame.size.height - CGRectGetHeight(view.frame)) / 2.0;
    
    CGFloat actualX = viewFrame.origin.x - scaleX;
    CGFloat actualY = viewFrame.origin.y - scaleY;
    
    if(self.clipType == ClipAreaViewTypeRect)
    {
        // 限定x,y,W,H
        if(actualX < 0 || actualY < 0) return;
        // 最大W,H
        if(viewFrame.size.width + actualX > CLIP_WIDTH || viewFrame.size.height + actualY > CLIP_HEIGHT) return;
        // 最小W,H
        if(viewFrame.size.width <= 100 || viewFrame.size.height <= 100) return;
        // 改变裁剪区域的frame
        view.frame = CGRectMake(actualX, actualY, viewFrame.size.width, viewFrame.size.height);
    }
    else
    {
        // 改变图片的frame
        view.frame = CGRectMake(actualX, actualY, viewFrame.size.width, viewFrame.size.height);
    }
}

/**
 *  一个手指移动结束后，重置被裁剪图片的frame
 */
- (void)correctClipImageViewFrame
{
    CGFloat clipImageX = CGRectGetMinX(self.clipImageView.frame);
    CGFloat clipImageY = CGRectGetMinY(self.clipImageView.frame);
    CGFloat clipImageW = CGRectGetWidth(self.clipImageView.frame);
    CGFloat clipImageH = CGRectGetHeight(self.clipImageView.frame);
    
    // 图片的X值最大不能超过裁剪区域的X值 最小不能小于..
    CGFloat actualX = MIN(MAX(CGRectGetMaxX(self.clipAreaView.clipView.frame) - clipImageW, clipImageX), CGRectGetMinX(self.clipAreaView.clipView.frame));
    // 图片的Y值最大不能超过裁剪区域的Y值 最小不能小于..
    CGFloat actualY = MIN(MAX(CGRectGetMaxY(self.clipAreaView.clipView.frame) - clipImageH, clipImageY), CGRectGetMinY(self.clipAreaView.clipView.frame));
    
    // 图片的宽高最大为自身宽高的1.5 最小为裁剪区域的直径+10 
    CGFloat actualW = MIN(MAX(CLIP_ARC_DIAMETER + 10, clipImageW), self.clipImage.size.width * 1.5);
    CGFloat actualH = MIN(MAX(CLIP_ARC_DIAMETER + 10, clipImageH), self.clipImage.size.height * 1.5);
    
    self.clipImageView.frame = CGRectMake(actualX, actualY, actualW, actualH);
}

#pragma mark -- 裁剪

- (UIImage *)getClipedImage
{
    if(self.clipType == ClipAreaViewTypeRect)
    {
        return [self clipImageWithRectangle]; // 矩形裁剪框
    }
    else // 圆形裁剪框
    {
        UIImage *subImage = [self clipImageWithRectangle];
        // 将裁剪出来的矩形修改成圆形
        CGFloat radius = MIN(subImage.size.width, subImage.size.height) / 2.0;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(subImage.size.width, subImage.size.height), NO, 0);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(subImage.size.width/2, subImage.size.height/2) radius:radius startAngle:0 endAngle:2*M_PI clockwise:0];
        [path addClip];
        [subImage drawAtPoint:CGPointZero];
        UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return clipImage;
    }
}

- (UIImage *)clipImageWithRectangle
{
    // 裁剪框是矩形时，self.clipAreaView与self.clipImageView的frame一样 所以转换坐标相当于没变
    // 裁剪框是圆形时，由于图片可以缩放，必须重新计算裁剪框的frame，主要是重算x,y
    CGRect convertFrame = [self.clipAreaView convertRect:self.clipAreaView.clipView.frame toView:self.clipImageView];
    
    //imageView的size可能和iamge的size不一样，而裁剪是按image的size算，这里必须换算
    CGFloat scaleW =  self.clipImage.size.width / self.clipImageView.frame.size.width;
    CGFloat scaleH =  self.clipImage.size.height / self.clipImageView.frame.size.height;
    // 实际需要裁剪的frame
    CGRect frame = CGRectMake(convertFrame.origin.x * scaleW, convertFrame.origin.y * scaleH, convertFrame.size.width * scaleW, convertFrame.size.height * scaleH);
    
    //NSLog(@"%@ %@", NSStringFromCGRect(self.clipImageView.frame), NSStringFromCGRect(self.clipAreaView.clipView.frame));
    // 这个方法所截出来的图是按原有图片的size算，不是你给出的imageView的size算
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.clipImageView.image.CGImage, frame);
    UIImage *subImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    //NSLog(@"%@", NSStringFromCGSize(subImage.size));
    return subImage;
}

- (void)dealloc
{
    if(self.clipType == ClipAreaViewTypeRect)
    {
        [self.clipAreaView removeObserver:self forKeyPath:@"clipView.frame"];
        [self.clipAreaView removeObserver:self forKeyPath:@"clipView.center"];
        
        [self.topLeftImageView removeGestureRecognizer:self.topLeftPan];
        [self.topRightImageView removeGestureRecognizer:self.topRightPan];
        [self.bottomLeftImageView removeGestureRecognizer:self.bottomLeftPan];
        [self.topRightImageView removeGestureRecognizer:self.bottomRightPan];
    }
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
        _clipAreaView.clipAreaType = self.clipType;
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
        [_topLeftImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCornerPan:)]];
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
        [_topRightImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCornerPan:)]];
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
        [_bottomLeftImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCornerPan:)]];
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
        [_bottomRightImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCornerPan:)]];
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
