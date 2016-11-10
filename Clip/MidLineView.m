//
//  MidLineView.m
//  ClipImage
//
//  Created by zhao on 16/11/4.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  中间线

#import "MidLineView.h"

@implementation MidLineView

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)heigth type:(MidLineViewType)type
{
    if([super init])
    {
        self.frame = CGRectMake(0, 0, width, heigth);
        self.backgroundColor = [UIColor clearColor];
        self.midLineWidth = width;
        self.midLineHeight = heigth;
        self.midLineType = type;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.midLineColor setStroke];
    CGContextSetLineWidth(context, MID_LINE_HEIGHT);
    
    switch (self.midLineType)
    {
        case MidLineViewTypeTop:
        case MidLineViewTypeBottom:
        {
            CGContextMoveToPoint(context, 0, self.midLineHeight/2.0);
            CGContextAddLineToPoint(context, self.midLineWidth, self.midLineHeight/2.0);
            break;
        }
            
        case MidLineViewTypeLeft:
        case MidLineViewTypeRight:
        {
            CGContextMoveToPoint(context, self.midLineWidth/2.0, 0);
            CGContextAddLineToPoint(context, self.midLineWidth/2.0, self.midLineHeight);
            break;
        }
    }
    CGContextStrokePath(context);
}

@end
