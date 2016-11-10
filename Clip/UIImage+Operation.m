//
//  UIImage+Operation.m
//  ClipImage
//
//  Created by zhao on 16/11/10.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "UIImage+Operation.h"

@implementation UIImage (Operation)

- (UIImage *)clipRectangleImageWithImageViewFrame:(CGRect)imageViewFrame
{
//    CGRect clipViewFrame = self.clipAreaView.clipView.frame;
//    CGFloat scaleW = self.size.width / imageViewFrame.size.width;
//    CGFloat scaleH = self.size.height / imageViewFrame.size.height;
//    // 实际需要裁剪的frame
//    CGRect frame = CGRectMake(clipViewFrame.origin.x * scaleW, clipViewFrame.origin.y * scaleH, clipViewFrame.size.width * scaleW, clipViewFrame.size.height * scaleH);
//    
//    //NSLog(@"%@ %@", NSStringFromCGRect(frame), NSStringFromCGRect(self.clipAreaView.clipView.frame));
//    // 这个方法所截出来的图是按原有图片的size算(329*329)，不是你给出的(320*250)算
//    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
//    UIImage *subImage = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//    //NSLog(@"%@", NSStringFromCGSize(subImage.size));
    return nil;
}

- (UIImage *)clipCircleImageWithImageViewFrame:(CGRect)imageViewFrame
{
    return nil;
}

@end
