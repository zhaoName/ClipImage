//
//  ViewController.m
//  ClipImage
//
//  Created by zhao on 16/11/1.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "ViewController.h"
#import "ClipViewController.h"

@interface ViewController ()<ClipViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *clipedImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ClipViewController"])
    {
        ClipViewController *clipVC = segue.destinationViewController;
        clipVC.delegate = self;
    }
}

- (void)didSuccessClipImage:(UIImage *)clipedImage
{
    self.clipedImageView.backgroundColor = [UIColor redColor];
    self.clipedImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.clipedImageView.image = clipedImage;
}


#pragma mark -- getter

@end
