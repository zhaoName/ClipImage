//
//  ClipViewController.h
//  ClipImage
//
//  Created by zhao on 16/11/1.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClipViewControllerDelegate <NSObject>

- (void)didSuccessClipImage:(UIImage *)clipedImage;

@end

@interface ClipViewController : UIViewController

@property (nonatomic, strong) UIImage *needClipImage;
@property (nonatomic, weak) id<ClipViewControllerDelegate> delegate;

@end
