//
//  RGBViewController.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/27.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "RGBViewController.h"
#import "Masonry.h"
#import "UIImage+Extension.h"
#import "ColorBoardViewController.h"
#import "OBShapedButton.h"

// Slider的宽度
static const CGFloat kSliderWidth = 160.f;
// 蓝牙传输数据的长度
static const NSInteger kDataLength = 20;

// 总开关对应value
static const NSInteger masterSwitchVal = 128;

// 接收Notify返回的code
static char backCode[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00};

// 开始连接的ServiceUUID
static NSString *const kStartServiceUUID = @"0xFFF0";
// 开始连接的CharacteristicUUID
static NSString *const kStartCharacteristicUUID = @"0xFFFA";

// 开始连接返回Notify的CharacteristicUUID
static NSString *const kStartNotifyCharacteristicUUID = @"0xFFFB";


@interface RGBViewController () <CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIButton *carBtn1;
@property (weak, nonatomic) IBOutlet UIButton *carBtn2;
@property (weak, nonatomic) IBOutlet UIButton *carBtn3;
@property (weak, nonatomic) IBOutlet UIButton *carBtn4;
@property (weak, nonatomic) IBOutlet UIButton *carBtn5;
@property (weak, nonatomic) IBOutlet UIButton *carBtn6;
@property (weak, nonatomic) IBOutlet UIView *eightBtnView;

@property (weak, nonatomic) IBOutlet UISwitch *masterSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectCarViewBottomCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *threeBtnViewBottomCons;

@property (weak, nonatomic) UISlider *leftSlider;
@property (weak, nonatomic) UISlider *rightSlider;

// 特征对象
@property (nonatomic, strong) CBCharacteristic *FFFAcharacteristic;
@property (nonatomic, strong) CBCharacteristic *FFFBcharacteristic;

// 蓝牙传输数据
@property (nonatomic, strong) NSMutableArray *transferCode;

// 6个车按钮对应的value
@property (nonatomic, strong) NSArray *carBtnValueArray;

// 6个车按钮对应的model临时value
@property (nonatomic, assign) NSInteger firstTmp;
@property (nonatomic, assign) NSInteger secondTmp;
@property (nonatomic, assign) NSInteger thirdTmp;
@property (nonatomic, assign) NSInteger fourthTmp;
@property (nonatomic, assign) NSInteger fifthTmp;
@property (nonatomic, assign) NSInteger sixthTmp;

// 8个ModelBtn
@property (nonatomic, strong) NSMutableArray *eightModelBtnArray;

// 保存选中的按钮数组
@property (nonatomic, strong) NSMutableArray *carSelectedBtnArray;

// 存储carBtn选中按钮的model值，key是carBtn的tag，value是modelBtn的tag
@property (nonatomic, strong) NSMutableDictionary *carSelectedModelDic;

// 亮度的值
@property (nonatomic, assign) NSInteger brightnessVal;
// 速度的值
@property (nonatomic, assign) NSInteger speedVal;
// 亮度的临时值
@property (nonatomic, assign) NSInteger brightnessTmpVal;
// 速度的临时值
@property (nonatomic, assign) NSInteger speedTmpVal;
// slider是否第一次发送数据
@property (nonatomic, assign, getter=isSliderFirstSend) BOOL sliderFirstSend;



@end

@implementation RGBViewController

- (NSMutableArray *)eightModelBtnArray {
    if (!_eightModelBtnArray) {
        _eightModelBtnArray = [NSMutableArray arrayWithCapacity:8];
    }
    
    return _eightModelBtnArray;
}

- (NSMutableDictionary *)carSelectedModelDic {
    if (!_carSelectedModelDic) {
        _carSelectedModelDic = [NSMutableDictionary dictionary];
    }
    return _carSelectedModelDic;
}

- (NSMutableArray *)carSelectedBtnArray {
    if (!_carSelectedBtnArray) {
        _carSelectedBtnArray = [NSMutableArray array];
    }
    
    return _carSelectedBtnArray;
}

- (NSArray *)carBtnValueArray {
    if (!_carBtnValueArray) {
        _carBtnValueArray = @[@1, @2, @4, @8, @16, @32];
    }
    
    return _carBtnValueArray;
}

- (NSMutableArray *)transferCode {
    if (!_transferCode) {
        _transferCode = [NSMutableArray arrayWithObjects:@76, @0, @(masterSwitchVal), @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, nil];
    }
    
    return _transferCode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpBackgroundIv];
    
    self.sliderFirstSend = YES;
    [self setUpSlider];
    
    [self setUpEightModelBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    // 针对不同手机，修改顶部距离
    if (screenHeight == 375) {
        self.selectCarViewBottomCons.constant = 52;
        self.threeBtnViewBottomCons.constant = 28;
    } else if (screenHeight == 414){
        self.selectCarViewBottomCons.constant = 62;
        self.threeBtnViewBottomCons.constant = 38;
    } else {
        self.selectCarViewBottomCons.constant = 20;
        self.threeBtnViewBottomCons.constant = 8;
    }
    
}

- (void)setMPeripheral:(CBPeripheral *)mPeripheral {
    _mPeripheral = mPeripheral;
    // 设置代理
    _mPeripheral.delegate = self;
    // 扫描服务
    [_mPeripheral discoverServices:nil];
}


- (void)dealloc {
    if (self.mPeripheral) {
        self.mPeripheral = nil;
    }
    
    NSLog(@"RGBViewController销毁");
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // 跳转到色盘界面
    ColorBoardViewController *destVc = segue.destinationViewController;
    [self.carSelectedBtnArray enumerateObjectsUsingBlock:^(UIButton *selectedBtn, NSUInteger idx, BOOL * _Nonnull stop) {
        // 把旧的colorTag传给destVc
        destVc.oldColorTag = [self.transferCode[selectedBtn.tag - 30000 + 12] integerValue];
        *stop = YES;
    }];
    
    
    destVc.confirmBlock = ^(NSInteger tag) {
        NSLog(@"tag=%zd", tag);
        
        // 遍历选中按钮数据，给每个选中按钮对应位赋值
        [self.carSelectedBtnArray enumerateObjectsUsingBlock:^(UIButton *selectedBtn, NSUInteger idx, BOOL * _Nonnull stop) {
            self.transferCode[selectedBtn.tag - 30000 + 12] = @(tag);
        }];
        
        if (self.masterSwitch.isOn) {
            [self writePeripheral:_mPeripheral characteristic:_FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.transferCode]];
        }
    };
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

/**
 *  设置背景图片
 */
- (void) setUpBackgroundIv{
    UIImageView *backgroundIv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewBg"]];
    [self.view addSubview:backgroundIv];
    [backgroundIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
    }];
}

/**
 *  设置左右Slider控件
 */
- (void)setUpSlider {
    UISlider *leftSlider = [[UISlider alloc] init];
    [self.view addSubview:leftSlider];
    [leftSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [leftSlider setMinimumTrackImage:[UIImage resizedImage:@"slider"] forState:UIControlStateNormal];
    [leftSlider setMaximumTrackImage:[UIImage resizedImage:@"slider"] forState:UIControlStateNormal];
    leftSlider.minimumValue=0.0f;
    leftSlider.maximumValue=15.0f;
    self.leftSlider = leftSlider;
    leftSlider.transform =  CGAffineTransformMakeRotation( -M_PI * 0.5 );
    [leftSlider addTarget:self action:@selector(brightnessOrSpeedSlider:) forControlEvents:UIControlEventValueChanged];
    [leftSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(-kSliderWidth * 0.5  + 25);
        make.centerY.equalTo(self.view.mas_centerY).offset(-20);
        make.width.mas_equalTo(kSliderWidth);
    }];
    
    UISlider *rightSlider = [[UISlider alloc] init];
    [self.view addSubview:rightSlider];
    [rightSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [rightSlider setMinimumTrackImage:[UIImage resizedImage:@"slider"] forState:UIControlStateNormal];
    [rightSlider setMaximumTrackImage:[UIImage resizedImage:@"slider"] forState:UIControlStateNormal];
    rightSlider.minimumValue=0.0f;
    rightSlider.maximumValue=15.0f;
    self.rightSlider = rightSlider;
    rightSlider.transform =  CGAffineTransformMakeRotation( -M_PI * 0.5 );
    [rightSlider addTarget:self action:@selector(brightnessOrSpeedSlider:) forControlEvents:UIControlEventValueChanged];
    [rightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(kSliderWidth * 0.5  - 25);
        make.centerY.equalTo(self.view.mas_centerY).offset(-20);
        make.width.mas_equalTo(kSliderWidth);
    }];
}

/**
 *  设置8个模态按钮
 */
- (void) setUpEightModelBtn {
    for (NSInteger i = 0; i < 8; i++) {
        //获取按钮图片的名称
        NSString *imageName = [NSString stringWithFormat:@"modelBtn%zd",i+1];
        NSString *selectedImageName = [NSString stringWithFormat:@"modelBtn%zd_selected", i+1];
        
        UIButton *btn = [OBShapedButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
        btn.tag = i + 40001;
        [btn addTarget:self action:@selector(modelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //往图片添加按钮
        [self.eightBtnView addSubview:btn];
        [self.eightModelBtnArray addObject:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.eightBtnView.mas_height);
            make.width.equalTo(self.eightBtnView.mas_width);
            make.left.equalTo(self.eightBtnView.mas_left);
            make.top.equalTo(self.eightBtnView.mas_top);
        }];
    }
}


// 写数据
-(void)writePeripheral:(CBPeripheral *)peripheral
        characteristic:(CBCharacteristic *)characteristic
                 value:(NSData *)value{
    
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast												= 0x01,
     CBCharacteristicPropertyRead													= 0x02,
     CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
     CBCharacteristicPropertyWrite													= 0x08,
     CBCharacteristicPropertyNotify													= 0x10,
     CBCharacteristicPropertyIndicate												= 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
     CBCharacteristicPropertyExtendedProperties										= 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
     };
     
     */
    NSLog(@"%lu", (unsigned long)characteristic.properties);
    
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
    
    
}

// 设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}


/**
 *  把发送的给蓝牙设备的数据从integer数组转为char数据，并把char数据转为NSData
 *
 */
- (NSData *) converToCharArrayWithIntegerArray:(NSMutableArray *) integerArray {
    
    char charArray[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

    char crcVal = 0;
    
    for (int i = 0; i < integerArray.count; i++) {
        
        crcVal += [integerArray[i] charValue];
        // 最后一位是把前面19位加起来的CRC位
        if (i == integerArray.count - 1) {
            charArray[i] = crcVal;
        } else {
            charArray[i] = [integerArray[i] charValue];
        }
    }
//    NSLog(@"%zd", [self.transferCode[4] integerValue]);
    return [NSData dataWithBytes:charArray length:integerArray.count];
}

/**
 *  CRC校验， 收到蓝牙设备返回数据时检验
 *
 */
- (BOOL) checkCRC:(char*)codes {
    // 计算CRC
    char ch[] = {0x00};
    for (int i = 0; i < kDataLength - 1; i++) {
        ch[0] += codes[i];
    }
    
    // 返回的CRC
    char backch[] = {0x00};
    backch[0] = codes[kDataLength - 1];
    
    NSString *calCRC = [[NSString alloc] initWithData:[NSData dataWithBytes:ch length:1]  encoding:NSUTF8StringEncoding];
    NSString *backCRC = [[NSString alloc] initWithData:[NSData dataWithBytes:backch length:1]  encoding:NSUTF8StringEncoding];
    
    // 比较CRC
    return [calCRC isEqualToString:backCRC];
}


/**
 *  车图片上的6个按钮点击总处理
 *
 *  @param btn 按钮
 *  @param obj 按钮对应的数组value
 */
- (void) carBtnClickWithBtn:(UIButton *)btn andObject:(id) obj {
    
    // 1.判断是否选中按钮数组里面的按钮
    __block BOOL found = NO;
    
    [self.carSelectedBtnArray enumerateObjectsUsingBlock:^(UIButton *selectedBtn, NSUInteger idx, BOOL * _Nonnull stop) {
        // 按钮在选中按钮数组里，标记并退出遍历
        if (selectedBtn.tag == btn.tag) {
            found = YES;
            *stop = YES;
        }
    }];
    
    
    if (found) {
        // 2.如果是，将按钮关闭
        btn.selected = !btn.selected;
    } else {
        // 3.如果不是，打开按钮，设置选中边框
        btn.selected = YES;
        [btn.layer setBorderWidth:5.0]; //边框宽度
        [btn.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
//        [btn.layer setCornerRadius:5.0];
        // 因为不在选中按钮数组里，要把之前的组里的按钮边框去掉
        [self.carSelectedBtnArray enumerateObjectsUsingBlock:^(UIButton *selectedBtn, NSUInteger idx, BOOL * _Nonnull stop) {
            [selectedBtn.layer setBorderWidth:0.0]; //边框宽度
            [selectedBtn.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
        }];
        // 移除所有按钮
        [self.carSelectedBtnArray removeAllObjects];
        
        // 把现在的按钮添加到选中数组里
        [self.carSelectedBtnArray addObject:btn];
    }
    
    
    if (btn.isSelected) {
        
        // 第2个字节(数组的第三位)，每选中一个按钮在原来的基础加上对应的value
        self.transferCode[2] = @([self.transferCode[2] integerValue] + [obj integerValue]);
        
    } else {

        // 第2个字节(数据的第三位)，每选中一个按钮在原来的基础减去对应的value
        self.transferCode[2] = @([self.transferCode[2] integerValue] - [obj integerValue]);
    }
    
    // 第3个字节(数组的第四位)，赋值操作的按钮对应的value
    self.transferCode[3] = obj;
    
    // 当每次点击carBtn时，重新对model按钮赋值
    // 1.把所有的model按钮取消选中
    [self.eightModelBtnArray makeObjectsPerformSelector:@selector(setSelected:) withObject:NO];
    // 2.把当前carBtn对应的model选中
    for (NSNumber *carSelectBtnTag in [self.carSelectedModelDic allKeys]) {
        // 当carBtn一样时才反选
        if (btn.tag == [carSelectBtnTag integerValue]) {
            [self.carSelectedModelDic objectForKey:carSelectBtnTag];
            UIButton *modelBtn = [self.view viewWithTag:[[self.carSelectedModelDic objectForKey:carSelectBtnTag] integerValue]];
            modelBtn.selected = !modelBtn.selected;
        }
    }
    
    
    if (self.masterSwitch.isOn) {
        [self writePeripheral:_mPeripheral characteristic:_FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.transferCode]];
    }
    
}

/**
 *  8个model按钮点击方法总处理
 *
 *  @param btn 按钮
 */
- (void) modelBtnClickWithBtn:(UIButton *)modelBtn{

    
    if (self.carSelectedBtnArray.count > 0) {
        // 1.反选按钮
        modelBtn.selected = !modelBtn.selected;
    }
    
    
    // 2.遍历选中按钮数组里面的按钮，计算选中按钮对应位的值
    for (UIButton *selectedBtn in self.carSelectedBtnArray) {
        
        // 3.之前选中的model反选
//        for (NSNumber *carSelectBtnTag in [self.carSelectedModelDic allKeys]) {
//            // 当carBtn一样时才反选
//            if (selectedBtn.tag == [carSelectBtnTag integerValue]) {
//                [self.carSelectedModelDic objectForKey:carSelectBtnTag];
//                UIButton *oldBtn = [self.view viewWithTag:[[self.carSelectedModelDic objectForKey:carSelectBtnTag] integerValue]];
//                oldBtn.selected = !oldBtn.selected;
//            }
//        }
        // 3.全部model取消选中
        [self.eightModelBtnArray makeObjectsPerformSelector:@selector(setSelected:) withObject:NO];
        
        // 4.存储选中carBtn的model，key是carBtn的tag，value是modelBtn的tag
        [self.carSelectedModelDic setObject:@(modelBtn.tag) forKey:@(selectedBtn.tag)];
        
        // 5.给选中的carBtn对应的model选中
        for (NSNumber *carSelectBtnTag in [self.carSelectedModelDic allKeys]) {
            // 当carBtn一样时才反选
            if (selectedBtn.tag == [carSelectBtnTag integerValue]) {
                [self.carSelectedModelDic objectForKey:carSelectBtnTag];
                UIButton *oldBtn = [self.view viewWithTag:[[self.carSelectedModelDic objectForKey:carSelectBtnTag] integerValue]];
                oldBtn.selected = !oldBtn.selected;
            }
        }
        
        // 计算公式：X * 16 + Y (X是第一个按钮的状态，Y是第二个按钮的状态)，以此类推
        // 判断是否是第几个carBtn
        switch (selectedBtn.tag - 30000) {
            case 1:
                // 如果模型按钮选中，赋值对应的modelVal
                if (modelBtn.isSelected) {
                    _firstTmp = (modelBtn.tag - 40000) * 16;
                }
                // 未选中，赋为0
                else {
                    _firstTmp = 0 * 16;
                }
                break;
            case 2:
                // 如果模型按钮选中，赋值对应的modelVal
                if (modelBtn.isSelected) {
                    _secondTmp = (modelBtn.tag - 40000);
                }
                // 未选中，赋为0
                else {
                    _secondTmp = 0;
                }
                break;
            case 3:
                // 如果模型按钮选中，赋值对应的modelVal
                if (modelBtn.isSelected) {
                    _thirdTmp = (modelBtn.tag - 40000) * 16;
                }
                // 未选中，赋为0
                else {
                    _thirdTmp = 0 * 16;
                }
                break;
            case 4:
                // 如果模型按钮选中，赋值对应的modelVal
                if (modelBtn.isSelected) {
                    _fourthTmp = (modelBtn.tag - 40000);
                }
                // 未选中，赋为0
                else {
                    _fourthTmp = 0;
                }
                break;
            case 5:
                // 如果模型按钮选中，赋值对应的modelVal
                if (modelBtn.isSelected) {
                    _fifthTmp = (modelBtn.tag - 40000) * 16;
                }
                // 未选中，赋为0
                else {
                    _fifthTmp = 0 * 16;
                }
                break;
            case 6:
                // 如果模型按钮选中，赋值对应的modelVal
                if (modelBtn.isSelected) {
                    _sixthTmp = (modelBtn.tag - 40000);
                }
                // 未选中，赋为0
                else {
                    _sixthTmp = 0;
                }
                break;
            default:
                break;
        }
        
        // 写数据
        self.transferCode[10] = @(_firstTmp + _secondTmp);
        self.transferCode[11] = @(_thirdTmp + _fourthTmp);
        self.transferCode[12] = @(_fifthTmp + _sixthTmp);
        if (self.masterSwitch.isOn) {
            [self writePeripheral:_mPeripheral characteristic:_FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.transferCode]];
        }
    }
    
    
}

#pragma mark - 按钮点击处理
/**
 *  总开关，开或关
 *
 */
- (IBAction)masterSwitchClick:(UISwitch *)sender {
    // 第2个字节(数组的第三位)，决定开或关
    if (sender.isOn) {
        self.transferCode[2] = @(masterSwitchVal);
    } else {
        self.transferCode[2] = @0;
    }
}


/**
 *  车图片上的6个按钮点击事件
 *
 */
- (IBAction)carBtnTouchUpInside:(UIButton *)sender {
    switch (sender.tag - 30000) {
        case 1:
            
            [self carBtnClickWithBtn:sender andObject:self.carBtnValueArray[0]];
            
            break;
        case 2:
            [self carBtnClickWithBtn:sender andObject:self.carBtnValueArray[1]];
            break;
        case 3:
            [self carBtnClickWithBtn:sender andObject:self.carBtnValueArray[2]];
            break;
        case 4:
            [self carBtnClickWithBtn:sender andObject:self.carBtnValueArray[3]];
            break;
        case 5:
            [self carBtnClickWithBtn:sender andObject:self.carBtnValueArray[4]];
            break;
        case 6:
            [self carBtnClickWithBtn:sender andObject:self.carBtnValueArray[5]];
            break;
        default:
            break;
    }
}

/**
 *  Slider值改变响应
 *
 */
- (void) brightnessOrSpeedSlider:(UISlider *)slider {

    // 亮度
    if (slider == self.leftSlider) {
        _brightnessTmpVal = [[NSNumber numberWithFloat:slider.value] integerValue];
    }
    // 速度
    else if(slider == self.rightSlider) {
        _speedTmpVal = [[NSNumber numberWithFloat:slider.value] integerValue];
    }
    
    
    // 第一次发送数据
    if (self.isSliderFirstSend) {
        if (self.masterSwitch.isOn) {
            _brightnessVal = _brightnessTmpVal;
            _speedVal = _speedTmpVal;
            
            // 遍历选中按钮数据，给每个选中按钮对应位赋值
            [self.carSelectedBtnArray enumerateObjectsUsingBlock:^(UIButton *selectedBtn, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger allVal = _brightnessVal * 16 + _speedVal;
                self.transferCode[selectedBtn.tag - 30000 + 3] = @(allVal);
            }];
            
            //        NSLog(@"%zd----%zd------%zd", _brightnessVal, _speedVal, _brightnessVal * 16 + _speedVal);
            [self writePeripheral:_mPeripheral characteristic:_FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.transferCode]];
            
            self.sliderFirstSend = NO;
        }
        
    } else {
        // 防止发送数据速度太快，当值不一样时才发送
        if (self.masterSwitch.isOn && (_brightnessVal != _brightnessTmpVal || _speedVal != _speedTmpVal)) {
            
            _brightnessVal = _brightnessTmpVal;
            _speedVal = _speedTmpVal;
            
            // 遍历选中按钮数据，给每个选中按钮对应位赋值
            [self.carSelectedBtnArray enumerateObjectsUsingBlock:^(UIButton *selectedBtn, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger allVal = _brightnessVal * 16 + _speedVal;
                self.transferCode[selectedBtn.tag - 30000 + 3] = @(allVal);
            }];
            
            //        NSLog(@"%zd----%zd------%zd", _brightnessVal, _speedVal, _brightnessVal * 16 + _speedVal);
            [self writePeripheral:_mPeripheral characteristic:_FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.transferCode]];
        }
    }
}

/**
 *  8个model按钮的点击
 *
 */
-(void)modelBtnClick:(UIButton *)btn{
//    switch (btn.tag - 40000) {
//        case 1:
//            [self modelBtnClickWithBtn:btn];
//            break;
//        case 2:
//            [self modelBtnClickWithBtn:btn];
//            break;
//        case 3:
//            [self modelBtnClickWithBtn:btn];
//            break;
//        case 4:
//            [self modelBtnClickWithBtn:btn];
//            break;
//        case 5:
//            [self modelBtnClickWithBtn:btn];
//            break;
//        case 6:
//            [self modelBtnClickWithBtn:btn];
//            break;
//        case 7:
//            [self modelBtnClickWithBtn:btn];
//            break;
//        case 8:
//            [self modelBtnClickWithBtn:btn];
//            break;
//        default:
//            break;
//    }
    
    [self modelBtnClickWithBtn:btn];
}

- (IBAction)backClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CBPeripheralDelegate
/*
 扫描到Services
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    } else {
        // 遍历查找到的服务
        CBUUID *serviceUUID=[CBUUID UUIDWithString:kStartServiceUUID];
        CBUUID *characteristicUUID=[CBUUID UUIDWithString:kStartCharacteristicUUID];
        CBUUID *notifyCharacteristicUUID=[CBUUID UUIDWithString:kStartNotifyCharacteristicUUID];
        for (CBService *service in peripheral.services) {
            if([service.UUID isEqual:serviceUUID]){
                // 外围设备查找指定服务中的特征
                [peripheral discoverCharacteristics:@[characteristicUUID, notifyCharacteristicUUID] forService:service];
            }
        }
    }
}

/*
 扫描到Characteristics特征
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    //遍历服务中的特征
    CBUUID *serviceUUID=[CBUUID UUIDWithString:kStartServiceUUID];
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kStartCharacteristicUUID];
    CBUUID *notifyCharacteristicUUID=[CBUUID UUIDWithString:kStartNotifyCharacteristicUUID];
    if ([service.UUID isEqual:serviceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:characteristicUUID]) {
                
                
                [self writePeripheral:peripheral characteristic:characteristic value:[self converToCharArrayWithIntegerArray:self.transferCode]];
                self.FFFAcharacteristic = characteristic;
                
            } else if ([characteristic.UUID isEqual:notifyCharacteristicUUID]) {
                //情景一：通知
                /*找到特征后设置外围设备为已通知状态（订阅特征）：
                 *1.调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
                 *2.调用此方法会触发外围设备的订阅代理方法
                 */
                [self notifyCharacteristic:peripheral characteristic:characteristic];
                self.FFFBcharacteristic = characteristic;
            }
        }
    }
    
}

/*
 特征值被更新后
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@"收到特征更新通知...");
    if (error) {
        NSLog(@"更新通知状态时发生错误，错误信息：%@",error.localizedDescription);
    }
    
    // 给特征值设置新的值
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kStartNotifyCharacteristicUUID];
    if ([characteristic.UUID isEqual:characteristicUUID]) {
        if (characteristic.isNotifying) {
            if (characteristic.properties == CBCharacteristicPropertyNotify) {
                NSLog(@"已订阅特征通知.");
                return;
            }else if (characteristic.properties == CBCharacteristicPropertyRead) {
                //从外围设备读取新值,调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
                [peripheral readValueForCharacteristic:characteristic];
            }
            
        }else{
            NSLog(@"停止已停止.");
        }
    }
}


/*
 更新特征值后（调用readValueForCharacteristic:方法或者外围设备在订阅后更新特征值都会调用此代理方法）
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"更新特征值时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    
    CBUUID *notifyCharacteristicUUID=[CBUUID UUIDWithString:kStartNotifyCharacteristicUUID];
    NSLog(@"%@", characteristic.UUID.UUIDString);
    if ([characteristic.UUID isEqual:notifyCharacteristicUUID]) {
        
        NSString *backDataString = [[NSString alloc] initWithBytes:[characteristic.value bytes] length:kDataLength encoding:NSUTF8StringEncoding];
        if (backDataString) {
            //打印出characteristic的UUID和值
            //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
            
            NSLog(@"返回的数据长度->%zd，值->%@", [characteristic.value length], backDataString);
            for (int i = 0; i < kDataLength; i++) {
                backCode[i] = [backDataString characterAtIndex:i];
            }
            
            // CRC校验
            if (![self checkCRC:backCode]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"CRC校验不正确" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
                return;
            }
            
            // 检测锁定
//            BOOL lockFlag = [self checkLock:backCode];
//            if (lockFlag) {
                //                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"设备已经被锁定" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                //                [alertView show];
                //                return;
//            }
        }else{
            NSLog(@"未发现特征值.");
        }
    }
}

/*
 写数据成功回调
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    //这个方法比较好，这个是你发数据到外设的某一个特征值上面，并且响应的类型是 CBCharacteristicWriteWithResponse ，上面的官方文档也有，如果确定发送到外设了，就会给你一个回应，当然，这个也是要看外设那边的特征值UUID的属性是怎么设置的,看官方文档，人家已经说了，条件是，特征值UUID的属性：CBCharacteristicWriteWithResponse
    if (!error) {
        NSLog(@"说明发送成功，characteristic.uuid为：%@",[characteristic.UUID UUIDString]);
        [self.mPeripheral readValueForCharacteristic:self.FFFAcharacteristic];
    }else{
        NSLog(@"发送失败了啊！characteristic.uuid为：%@",[characteristic.UUID UUIDString]);
    }
    
}



//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
    
}
//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}


@end
