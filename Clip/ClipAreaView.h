//
//  ClipAreaView.h
//  ClipImage
//
//  Created by zhao on 16/11/1.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  裁剪区域

#import <UIKit/UIKit.h>

#define CLIP_WIDTH self.frame.size.width
#define CLIP_HEIGHT self.frame.size.height

typedef NS_ENUM(NSUInteger, ClipAreaViewType)
{
    ClipAreaViewTypeRect = 0, /**< 裁剪区域是矩形*/
    ClipAreaViewTypeArc, /**< 裁剪区域是圆形*/
};

@interface ClipAreaView : UIView

@property (nonatomic, strong) UIView *clipView; /**< 裁剪区域*/
@property (nonatomic, assign) ClipAreaViewType clipAreaType;

/**
 *  快速初始化ClipAreaView类
 */
+ (instancetype)initWithFrame:(CGRect)frame;

- (void)resetClipViewFrame;

@end
