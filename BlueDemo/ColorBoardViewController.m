//
//  ColorBoardViewController.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/29.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "ColorBoardViewController.h"
#import "Masonry.h"
#import "UIImage+ColorAtPixel.h"
#import "JHConst.h"

@interface ColorBoardViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *circleImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

// 色块十六进制数组
@property (nonatomic, strong) NSArray *colorList;

// 选中色块的tag
@property (nonatomic, assign) NSInteger currentColorTag;

// 是否第一次发送数据
@property (nonatomic, assign, getter=isFirstSend) BOOL firstSend;

@property (nonatomic,strong) UIImageView *wheelKnobView;

@end

@implementation ColorBoardViewController

- (NSArray *)colorList {
    if (!_colorList) {
        _colorList = @[@"0xee1e25",
                       @"0xf15b40",
                       @"0xf58466",
                       @"0xf9aa8f",
                       @"0xfaa51a",
                       @"0xfcb54c",
                       @"0xfec679",
                       @"0xffd8a1",
                       @"0xf4eb21",
                       @"0xf6ee60",
                       @"0xf8f18c",
                       @"0xfaf5b2",
                       @"0x9aca3b",
                       @"0xaed361",
                       @"0xc1dc89",
                       @"0xd4e6ae",
                       @"0x71c054",
                       @"0x8dca76",
                       @"0xaad595",
                       @"0xc5e2b5",
                       @"0x70c6a5",
                       @"0x8dcfb5",
                       @"0xaadac6",
                       @"0xc5e5d7",
                       @"0x40b9eb",
                       @"0x70c4ee",
                       @"0x96d0f2",
                       @"0xb8ddf6",
                       @"0x426fb6",
                       @"0x6683c1",
                       @"0x889bcf",
                       @"0xaab7dd",
                       @"0x5b51a3",
                       @"0x756bb1",
                       @"0x9087c0",
                       @"0xafa9d3",
                       @"0x8750a0",
                       @"0x996daf",
                       @"0xac8bc0",
                       @"0xafa9d3",
                       @"0xd0499a",
                       @"0xd771ad",
                       @"0xdf92bf",
                       @"0xe7b3d3",
                       @"0xed187a",
                       @"0xf05e90",
                       @"0xf388a7",
                       @"0xf7aec0",
                       @"0xfeffff"];
    }
    return _colorList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置第一次发送数据
    self.firstSend = YES;
    
    [self p_SetUpWheel];
    
}

- (void)dealloc {
    JHLog(@"ColorBoardViewController销毁");
}


#pragma mark - 横屏设置
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
/**
 *  添加色块到View上
 */
- (void) p_SetUpWheel{
    
    // 拖拽手势
    UIPanGestureRecognizer *panGestureRecognizer;
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.circleImageView addGestureRecognizer:panGestureRecognizer];
    
    // 敲击手势
    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.circleImageView addGestureRecognizer:tapGestureRecognizer];
    self.circleImageView.userInteractionEnabled = YES;
    
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateEnded) {
        if (sender.numberOfTouches <= 0) {
            return;
        }
        CGPoint tapPoint = [sender locationOfTouch:0 inView:self.circleImageView];
        
        RGBType rgba = [self.circleImageView.image colorAtPixel2:tapPoint];
        NSInteger hex = RGB_to_HEX(rgba.r, rgba.g, rgba.b);
        NSString *hexString = [NSString stringWithFormat:@"0x%06lx", (long)hex];
//        JHLog(@"%@", hexString);
        [self.colorList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:hexString]) {
//                JHLog(@"%zd",idx);
                // 第一次发送数据不用判断值是否相同
                if (self.isFirstSend) {
                    _currentColorTag = idx;
                    __weak typeof(self) weakSelf = self;
                    // 回调block
                    self.confirmBlock(weakSelf.currentColorTag);
                    self.firstSend = NO;
                } else {
                    // 防止传输速度过快，当值不同的时候才回调
                    if (_currentColorTag != idx) {
                        _currentColorTag = idx;
                        __weak typeof(self) weakSelf = self;
                        // 回调block
                        self.confirmBlock(weakSelf.currentColorTag);
                    }
                }
            }
        }];
        
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender.numberOfTouches <= 0) {
            return;
        }
        CGPoint tapPoint = [sender locationOfTouch:0 inView:self.circleImageView];
        
        RGBType rgba = [self.circleImageView.image colorAtPixel2:tapPoint];
        NSInteger hex = RGB_to_HEX(rgba.r, rgba.g, rgba.b);
        NSString *hexString = [NSString stringWithFormat:@"0x%06lx", (long)hex];
//        JHLog(@"%@", hexString);
        [self.colorList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:hexString]) {
//                JHLog(@"%zd",idx);
                // 第一次发送数据不用判断值是否相同
                if (self.isFirstSend) {
                    _currentColorTag = idx;
                    __weak typeof(self) weakSelf = self;
                    // 回调block
                    self.confirmBlock(weakSelf.currentColorTag);
                    self.firstSend = NO;
                } else {
                    // 防止传输速度过快，当值不同的时候才回调
                    if (_currentColorTag != idx) {
                        _currentColorTag = idx;
                        __weak typeof(self) weakSelf = self;
                        // 回调block
                        self.confirmBlock(weakSelf.currentColorTag);
                    }
                }
            }
        }];
    }
}

- (IBAction)confirmClick:(UIButton *)sender {
    
    // 把选中的色块赋值给confirmTag
    __weak typeof(self) weakSelf = self;
    // 回调block
    self.confirmBlock(weakSelf.currentColorTag);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backClick:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    // 回调block
    self.confirmBlock(weakSelf.oldColorTag);
    [self dismissViewControllerAnimated:YES completion:nil];
}





@end
