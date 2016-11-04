//
//  MidLineView.h
//  ClipImage
//
//  Created by zhao on 16/11/4.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MID_LINE_WIDTH 30
#define MID_LINE_HEIGHT 5
#define MID_LINE_INVISIBLE 25

typedef NS_ENUM(NSInteger, MidLineViewType)
{
    MidLineViewTypeTop = 0,
    MidLineViewTypeLeft,
    MidLineViewTypeBottom,
    MidLineViewTypeRight,
};

@interface MidLineView : UIView

@property (nonatomic, assign) CGFloat midLineWidth;
@property (nonatomic, assign) CGFloat midLineHeight;
@property (nonatomic, assign) MidLineViewType midLineType;
@property (nonatomic, strong) UIColor *midLineColor;

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)heigth type:(MidLineViewType)type;

@end
