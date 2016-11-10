//
//  UIImage+Operation.h
//  ClipImage
//
//  Created by zhao on 16/11/10.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Operation)

/**
 *  裁剪图片，裁剪后的图片的形状是矩形
 *
 *  @param imageViewFrame image所在imageView的frame
 *
 *  @return 裁剪后的图片
 */
- (UIImage *)clipRectangleImageWithImageViewFrame:(CGRect)imageViewFrame;


/**
 *  裁剪图片，裁剪后的图片的形状是圆形
 *
 *  @param imageViewFrame image所在imageView的frame
 *
 *  @return 裁剪后的图片
 */
- (UIImage *)clipCircleImageWithImageViewFrame:(CGRect)imageViewFrame;


@end
