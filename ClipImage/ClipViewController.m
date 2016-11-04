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
    
    
    [self.view addSubview:self.clipImageView];
    self.clipImageView.clipImage = [UIImage imageNamed:@"dog"];
}


- (IBAction)cancelClipImage:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)successClipImage:(UIBarButtonItem *)sender
{
    UIImage *clipedImage = [self.clipImageView getClipedImage];
    if([self.delegate respondsToSelector:@selector(didSuccessClipImage:)])
    {
        [self.delegate didSuccessClipImage:clipedImage];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
        _clipImageView = [ClipImageView initWithFrame:CGRectMake(0, 200, Screen_Width, 250)];
        _clipImageView.midLineColor = [UIColor redColor];
    }
    return _clipImageView;
}


@end
