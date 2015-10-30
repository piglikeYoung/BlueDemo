//
//  ColorBoardViewController.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/29.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "ColorBoardViewController.h"
#import "YJHColorPickerHSWheel.h"
#import "Masonry.h"

@interface ColorBoardViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *circleImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

// 色块图片数组
@property (nonatomic, strong) NSMutableArray *colorList;

// 选中色块的tag
@property (nonatomic, assign) NSInteger currentColorTag;

// 是否第一次发送数据
@property (nonatomic, assign, getter=isFirstSend) BOOL firstSend;

@end

@implementation ColorBoardViewController

- (NSMutableArray *)colorList {
    if (!_colorList) {
        _colorList = [NSMutableArray array];
    }
    return _colorList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstSend = YES;
    
    [self p_SetUpWheel];
}

- (void)dealloc {
    NSLog(@"ColorBoardViewController销毁");
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
    
    for (NSInteger i = 0; i < 3; i++) {
        // 获取色块图片的名称
        NSString *imageName = [NSString stringWithFormat:@"circle%zd",i+1];
        
        // 添加色块
        YJHColorPickerHSWheel *iv = [[YJHColorPickerHSWheel alloc] initWithImage:[UIImage imageNamed:imageName]];
        iv.tag = i;
        iv.userInteractionEnabled = YES;
        // 添加到View
        [self.circleImageView addSubview:iv];
        [self.colorList addObject:iv];
        
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.circleImageView.mas_width);
            make.height.equalTo(self.circleImageView.mas_height);
            make.top.equalTo(self.circleImageView.mas_top);
            make.left.equalTo(self.circleImageView.mas_left);
        }];
    }
    
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateEnded) {
        if (sender.numberOfTouches <= 0) {
            return;
        }
        CGPoint tapPoint = [sender locationOfTouch:0 inView:self.circleImageView];
        for (YJHColorPickerHSWheel *colorIv in self.colorList) {
            if ([colorIv pointInside:tapPoint withEvent:nil]) {
                // 第一次发送数据不用判断值是否相同
                if (self.isFirstSend) {
                    _currentColorTag = colorIv.tag;
                    __weak typeof(self) weakSelf = self;
                    // 回调block
                    self.confirmBlock(weakSelf.currentColorTag);
                    self.firstSend = NO;
                } else {
                    // 防止传输速度过快，当值不同的时候才回调
                    if (_currentColorTag != colorIv.tag) {
                        _currentColorTag = colorIv.tag;
                        __weak typeof(self) weakSelf = self;
                        // 回调block
                        self.confirmBlock(weakSelf.currentColorTag);
                    }
                }
            }
            
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender.numberOfTouches <= 0) {
            return;
        }
        CGPoint tapPoint = [sender locationOfTouch:0 inView:self.circleImageView];
        for (YJHColorPickerHSWheel *colorIv in self.colorList) {
            if ([colorIv pointInside:tapPoint withEvent:nil]) {
                
                // 第一次发送数据不用判断值是否相同
                if (self.isFirstSend) {
                    _currentColorTag = colorIv.tag;
                    __weak typeof(self) weakSelf = self;
                    // 回调block
                    self.confirmBlock(weakSelf.currentColorTag);
                    self.firstSend = NO;
                } else {
                    // 防止传输速度过快，当值不同的时候才回调
                    if (_currentColorTag != colorIv.tag) {
                        _currentColorTag = colorIv.tag;
                        __weak typeof(self) weakSelf = self;
                        // 回调block
                        self.confirmBlock(weakSelf.currentColorTag);
                    }
                }
                
            }
        }
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
