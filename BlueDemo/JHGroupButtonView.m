//
//  JHGroupButtonView.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/12/5.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "JHGroupButtonView.h"
#import "JHConst.h"

@interface JHGroupButtonView()

@property (weak, nonatomic) IBOutlet UIButton *carBtn1;
@property (weak, nonatomic) IBOutlet UIButton *carBtn2;
@property (weak, nonatomic) IBOutlet UIButton *carBtn3;
@property (weak, nonatomic) IBOutlet UIButton *carBtn4;
@property (weak, nonatomic) IBOutlet UIButton *carBtn5;
@property (weak, nonatomic) IBOutlet UIButton *carBtn6;

// 保存有边框的按钮
@property (nonatomic, strong) NSMutableArray *carBorderBtnArray;

// 6个按钮有边框对应的值
@property (nonatomic, strong) NSArray *carBtnValues;

@end

@implementation JHGroupButtonView

- (NSMutableArray *)carBorderBtnArray {
    if (!_carBorderBtnArray) {
        _carBorderBtnArray = [NSMutableArray arrayWithCapacity:6];
    }
    return _carBorderBtnArray;
}

- (NSArray *)carBtnValues {
    if (!_carBtnValues) {
        _carBtnValues = @[@1, @2, @4, @8, @16, @32];
    }
    return _carBtnValues;
}

+ (instancetype)showView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"JHGroupButtonView" owner:nil options:nil] firstObject];
}

- (void)setRecoveryCode:(NSMutableArray *)recoveryCode  {
    _recoveryCode = [recoveryCode mutableCopy];
    
    // 根据数组恢复开关按钮状态
    [self recoveryCarBtnValueWithIntegerArray:_recoveryCode];
    
    // 根据数组恢复开关的边框
    [self recoveryOperationBtnValueWithIntegerArray:_recoveryCode];
}

#pragma mark - 按钮点击
- (IBAction)btnClick:(UIButton *)btn {
    
    NSInteger index = btn.tag - 60001;
    
    // 1.判断是否选中按钮数组里面的按钮
    __block BOOL found = NO;
    
    [self.carBorderBtnArray enumerateObjectsUsingBlock:^(UIButton *selectedBtn, NSUInteger idx, BOOL * _Nonnull stop) {
        // 按钮在选中按钮数组里，标记并退出遍历
        if (selectedBtn.tag == btn.tag) {
            found = YES;
            *stop = YES;
        }
    }];
    
    if (found) {
        // 2.如果是，去掉边框
        [btn.layer setBorderWidth:0.0]; //边框宽度
        [btn.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
        
        // 第3个字节(数据的第四位)，每选中一个按钮在原来的基础减去对应的value
        self.recoveryCode[3] = @([self.recoveryCode[3] integerValue] - [self.carBtnValues[index] integerValue]);
        
        // 移除按钮
        [self.carBorderBtnArray removeObject:btn];
        
    } else {
        // 3.如果不是，加上边框
        [btn.layer setBorderWidth:2.0]; //边框宽度
        [btn.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色

        // 第3个字节(数据的第四位)，每选中一个按钮在原来的基础加上对应的value
        self.recoveryCode[3] = @([self.recoveryCode[3] integerValue] + [self.carBtnValues[index] integerValue]);
        
        // 把现在的按钮添加到选中数组里
        [self.carBorderBtnArray addObject:btn];
    }

}
- (IBAction)cancelBtnClick:(id)sender {
    
    [self removeFromSuperview];
    self.multipleCanelClickBlock();
}

- (IBAction)confirmBtnClick:(id)sender {
    self.multipleSelectedClickBlock(self.recoveryCode);
    [self removeFromSuperview];
}

#pragma mark - 回显方法
/**
 *  根据数组恢复开关按钮状态
 *
 */
- (void)recoveryCarBtnValueWithIntegerArray:(NSArray *)integerArray {
    
    NSInteger carBtnValue = [integerArray[2] integerValue];
    
    
    // 判断灯1
    if (((carBtnValue / 1) % 2) == 1) {
        self.carBtn1.selected = YES;
        
    } else {
        self.carBtn1.selected = NO;
    }
    // 判断灯2
    if (((carBtnValue / 2) % 2) == 1) {
        self.carBtn2.selected = YES;
    } else {
        self.carBtn2.selected = NO;
    }
    // 判断灯3
    if (((carBtnValue / 4) % 2) == 1) {
        self.carBtn3.selected = YES;
    } else {
        self.carBtn3.selected = NO;
    }
    // 判断灯4
    if (((carBtnValue / 8) % 2) == 1) {
        self.carBtn4.selected = YES;
    } else {
        self.carBtn4.selected = NO;
    }
    // 判断灯5
    if (((carBtnValue / 16) % 2) == 1) {
        self.carBtn5.selected = YES;
    } else {
        self.carBtn5.selected = NO;
    }
    // 判断灯6
    if (((carBtnValue / 32) % 2) == 1) {
        self.carBtn6.selected = YES;
    } else {
        self.carBtn6.selected = NO;
    }
    
}

/**
 *  根据数组恢复开关的边框
 *
 */
- (void)recoveryOperationBtnValueWithIntegerArray:(NSArray *)integerArray {
    
    // 恢复前先移除所有的btn
    [self.carBorderBtnArray removeAllObjects];
    
    NSInteger value = [integerArray[3] integerValue];
    
    // 判断灯1
    if (((value / 1) % 2) == 1) {
        // 把选中的按钮添加到选中数组中
        [self.carBorderBtnArray addObject:self.carBtn1];
        [self.carBtn1.layer setBorderWidth:2.0]; //边框宽度
        [self.carBtn1.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
        // 把选中的按钮添加到选中数组中
        [self.carBorderBtnArray addObject:self.carBtn1];
    } else {
        [self.carBtn1.layer setBorderWidth:0.0]; //边框宽度
        [self.carBtn1.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
    }
    
    // 判断灯2
    if (((value / 2) % 2) == 1) {
        [self.carBorderBtnArray addObject:self.carBtn2];
        [self.carBtn2.layer setBorderWidth:2.0]; //边框宽度
        [self.carBtn2.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
        // 把选中的按钮添加到选中数组中
        [self.carBorderBtnArray addObject:self.carBtn2];
    } else {
        [self.carBtn2.layer setBorderWidth:0.0]; //边框宽度
        [self.carBtn2.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
    }
    
    // 判断灯3
    if (((value / 4) % 2) == 1) {
        [self.carBorderBtnArray addObject:self.carBtn3];
        [self.carBtn3.layer setBorderWidth:2.0]; //边框宽度
        [self.carBtn3.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
        // 把选中的按钮添加到选中数组中
        [self.carBorderBtnArray addObject:self.carBtn3];
    } else {
        [self.carBtn3.layer setBorderWidth:0.0]; //边框宽度
        [self.carBtn3.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
    }
    
    // 判断灯4
    if (((value / 8) % 2) == 1) {
        [self.carBorderBtnArray addObject:self.carBtn4];
        [self.carBtn4.layer setBorderWidth:2.0]; //边框宽度
        [self.carBtn4.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
        // 把选中的按钮添加到选中数组中
        [self.carBorderBtnArray addObject:self.carBtn4];
    } else {
        [self.carBtn4.layer setBorderWidth:0.0]; //边框宽度
        [self.carBtn4.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
    }
    
    // 判断灯5
    if (((value / 16) % 2) == 1) {
        [self.carBorderBtnArray addObject:self.carBtn5];
        [self.carBtn5.layer setBorderWidth:2.0]; //边框宽度
        [self.carBtn5.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
        // 把选中的按钮添加到选中数组中
        [self.carBorderBtnArray addObject:self.carBtn5];
    } else {
        [self.carBtn5.layer setBorderWidth:0.0]; //边框宽度
        [self.carBtn5.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
    }
    
    // 判断灯6
    if (((value / 32) % 2) == 1) {
        [self.carBorderBtnArray addObject:self.carBtn6];
        [self.carBtn6.layer setBorderWidth:2.0]; //边框宽度
        [self.carBtn6.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
        // 把选中的按钮添加到选中数组中
        [self.carBorderBtnArray addObject:self.carBtn6];
    } else {
        [self.carBtn6.layer setBorderWidth:0.0]; //边框宽度
        [self.carBtn6.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
    }
}


@end
