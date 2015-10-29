//
//  RGBViewController.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/27.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "RGBViewController.h"
#import "Masonry.h"

static const CGFloat kSliderWidth = 160.f;

@interface RGBViewController ()
@property (weak, nonatomic) UISlider *leftSlider;
@property (weak, nonatomic) UISlider *rightSlider;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIStackView *modelStackView;

@end

@implementation RGBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpSlider];
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
- (void)setUpSlider {
    UISlider *leftSlider = [[UISlider alloc] init];
    [self.view addSubview:leftSlider];
    self.leftSlider = leftSlider;
    leftSlider.transform =  CGAffineTransformMakeRotation( -M_PI * 0.5 );
    [leftSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(-kSliderWidth * 0.5  + 25);
        make.centerY.equalTo(self.view.mas_centerY).offset(-20);
        make.width.mas_equalTo(kSliderWidth);
    }];
    
    UISlider *rightSlider = [[UISlider alloc] init];
    [self.view addSubview:rightSlider];
    self.rightSlider = rightSlider;
    rightSlider.transform =  CGAffineTransformMakeRotation( -M_PI * 0.5 );
    [rightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(kSliderWidth * 0.5  - 25);
        make.centerY.equalTo(self.view.mas_centerY).offset(-20);
        make.width.mas_equalTo(kSliderWidth);
    }];
}


- (IBAction)backClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
