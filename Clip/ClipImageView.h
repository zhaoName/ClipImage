//
//  ClipImageView.h
//  ClipImage
//
//  Created by zhao on 16/11/1.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClipImageView : UIView


@property (nonatomic, strong) UIImage *clipImage; /**< 需要被裁剪的图片*/
@property (nonatomic, strong) UIColor *midLineColor; /**< 中间线颜色*/


/**
 *  快速初始化ClipImageView类
 */
+ (instancetype)initWithFrame:(CGRect)frame;

/**
 *  获取裁剪后的图片
 */
- (UIImage *)getClipedImage;

@end
