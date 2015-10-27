//
//  RGBViewController.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/27.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "RGBViewController.h"

@interface RGBViewController ()

@end

@implementation RGBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    NSLog(@"RGBViewController销毁");
}

#pragma mark 横屏设置
- (BOOL) shouldAutorotate{
    return YES;
    
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

#pragma mark - 私有方法
- (IBAction)backClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
