//
//  ClipViewController.m
//  ClipImage
//
//  Created by zhao on 16/11/1.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "ClipViewController.h"
#import "ClipImageView.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@interface ClipViewController ()

@property (nonatomic, strong) ClipImageView *clipImageView;

@end

@implementation ClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"图片裁剪";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClipImage:)];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(successClipImage:)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.clipImageView];
    self.clipImageView.clipImage = self.needClipImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 从相机界面跳转会默认隐藏导航栏
    self.navigationController.navigationBarHidden = NO;
}

// 取消裁剪
- (void)cancelClipImage:(UIBarButtonItem *)sender
{
    if([self.delegate respondsToSelector:@selector(didSuccessClipImage:)])
    {
        [self.delegate didSuccessClipImage:nil];
    }
}

// 裁剪成功
- (void)successClipImage:(UIBarButtonItem *)sender
{
    UIImage *clipedImage = [self.clipImageView getClipedImage];
    if([self.delegate respondsToSelector:@selector(didSuccessClipImage:)])
    {
        [self.delegate didSuccessClipImage:clipedImage];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"didReceiveMemoryWarning");
}

#pragma mark -- getter

- (ClipImageView *)clipImageView
{
    if(!_clipImageView)
    {
        _clipImageView = [ClipImageView initWithFrame:CGRectMake(0, 100, Screen_Width, 400)];
        //_clipImageView.contentMode = UIViewContentModeScaleAspectFit;
        _clipImageView.midLineColor = [UIColor redColor];
        _clipImageView.clipType = ClipAreaViewTypeArc;
    }
    return _clipImageView;
}


@end
