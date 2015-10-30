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

@property (nonatomic, strong) NSMutableArray *colorList;

@property (nonatomic, assign) CGPoint previousTouchPoint;
@property (nonatomic, assign) BOOL previousTouchHitTestResponse;

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
    
    [self p_SetUpWheel];
}

/**
 *  添加色块到View上
 */
- (void) p_SetUpWheel{
    UIPanGestureRecognizer *panGestureRecognizer;
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.circleImageView addGestureRecognizer:panGestureRecognizer];
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
                NSLog(@"%zd", colorIv.tag);
            }
            
        }
    }
}



- (void)dealloc {
    NSLog(@"ColorBoardViewController销毁");
}

- (IBAction)backClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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



@end
