//
//  SwitchViewController.m
//  BleDemo
//
//  Created by piglikeyoung on 15/10/11.
//  Copyright © 2015年 liuyanwei. All rights reserved.
//

#import "SwitchViewController.h"
#import "JHConst.h"

// 需要MacAddress的长度
static const NSInteger kMacAddressLength = 6;
// 蓝牙传输数据的长度
static const NSInteger kDataLength = 11;

// 开始连接的ServiceUUID
static NSString *const kStartServiceUUID = @"0xFFF0";
// 开始连接的CharacteristicUUID
static NSString *const kStartCharacteristicUUID = @"0xFFFA";

// 开始连接返回Notify的CharacteristicUUID
static NSString *const kStartNotifyCharacteristicUUID = @"0xFFFB";

// 一开始发送的code
static char startCode[] = {0x4e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00};

// 接收Notify返回的code
static char backCode[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00};

// 锁定设备数据
static char lockSendCode[] = {0x4d, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00};
// 解锁设备数据
static char unlockSendCode[] = {0x4d, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00};


// 模式类型枚举
typedef enum {
    kAllClose,
    kStrobe,
    kFlash,
    kMomenyary
} ModelTypes;

// 模式三索引
//static const NSInteger kMomenyary = 2;

@interface SwitchViewController ()<CBPeripheralDelegate>

// 特征对象
@property (nonatomic, strong) CBCharacteristic *FFFAcharacteristic;
@property (nonatomic, strong) CBCharacteristic *FFFBcharacteristic;



// 记录哪盏灯亮着（控制的是全部灯 则该字节为 1+2+4+8+16+32；控制第一个灯	则该字节为1）
@property (nonatomic, assign) NSInteger whickLamp;

// 记录状态要发送的16进制值
@property (nonatomic, strong) NSArray *statusHex;
// 记录每个Model的当前状态
@property (nonatomic, strong) NSMutableArray *allLabelStatus;


@property (weak, nonatomic) IBOutlet UIImageView *offFlay1;
@property (weak, nonatomic) IBOutlet UIImageView *offFlay2;
@property (weak, nonatomic) IBOutlet UIImageView *offFlay3;
@property (weak, nonatomic) IBOutlet UIImageView *offFlay4;
@property (weak, nonatomic) IBOutlet UIImageView *offFlay5;
@property (weak, nonatomic) IBOutlet UIImageView *offFlay6;

@property (weak, nonatomic) IBOutlet UIButton *onOffBtn1;
@property (weak, nonatomic) IBOutlet UIButton *onOffBtn2;
@property (weak, nonatomic) IBOutlet UIButton *onOffBtn3;
@property (weak, nonatomic) IBOutlet UIButton *onOffBtn4;
@property (weak, nonatomic) IBOutlet UIButton *onOffBtn5;
@property (weak, nonatomic) IBOutlet UIButton *onOffBtn6;

@property (weak, nonatomic) IBOutlet UIButton *modelBtn1;
@property (weak, nonatomic) IBOutlet UIButton *modelBtn2;
@property (weak, nonatomic) IBOutlet UIButton *modelBtn3;
@property (weak, nonatomic) IBOutlet UIButton *modelBtn4;
@property (weak, nonatomic) IBOutlet UIButton *modelBtn5;
@property (weak, nonatomic) IBOutlet UIButton *modelBtn6;

@property (weak, nonatomic) IBOutlet UIImageView *strobeIv1;
@property (weak, nonatomic) IBOutlet UIImageView *strobeIv2;
@property (weak, nonatomic) IBOutlet UIImageView *strobeIv3;
@property (weak, nonatomic) IBOutlet UIImageView *strobeIv4;
@property (weak, nonatomic) IBOutlet UIImageView *strobeIv5;
@property (weak, nonatomic) IBOutlet UIImageView *strobeIv6;

@property (weak, nonatomic) IBOutlet UIImageView *flashIv1;
@property (weak, nonatomic) IBOutlet UIImageView *flashIv2;
@property (weak, nonatomic) IBOutlet UIImageView *flashIv3;
@property (weak, nonatomic) IBOutlet UIImageView *flashIv4;
@property (weak, nonatomic) IBOutlet UIImageView *flashIv5;
@property (weak, nonatomic) IBOutlet UIImageView *flashIv6;

@property (weak, nonatomic) IBOutlet UIImageView *momentaryIv1;
@property (weak, nonatomic) IBOutlet UIImageView *momentaryIv2;
@property (weak, nonatomic) IBOutlet UIImageView *momentaryIv3;
@property (weak, nonatomic) IBOutlet UIImageView *momentaryIv4;
@property (weak, nonatomic) IBOutlet UIImageView *momentaryIv5;
@property (weak, nonatomic) IBOutlet UIImageView *momentaryIv6;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoIvTopCons;

//@property (weak, nonatomic) IBOutlet UISwitch *lockSwichBtn;

// 开关和模式按钮发送的数据
@property (nonatomic, strong) NSMutableArray *offOnAndStatusbtnSendCode;

@end

@implementation SwitchViewController

- (NSMutableArray *)offOnAndStatusbtnSendCode {
    if (!_offOnAndStatusbtnSendCode) {
        _offOnAndStatusbtnSendCode = [NSMutableArray arrayWithObjects:@76, @0, @0, @0, @0, @0, @0, @0 , @0, @0, @0, nil];
    }
    
    return _offOnAndStatusbtnSendCode;
}


/**
 *  连接蓝牙马上发送的数据，把手机的uuid发过去
 *
 */
- (NSData *) startCode {
    NSString *identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *subid = [identifierForVendor substringWithRange: NSMakeRange(0, kMacAddressLength)];
    for (int i = 0; i < kMacAddressLength; i++) {
        startCode[i + 1] = [subid characterAtIndex:i];
    }
    return [self convertCode:startCode];
}


- (NSArray *)statusHex {
    if (!_statusHex) {
        _statusHex = @[@0, @1, @2, @3, @4];
    }
    return _statusHex;
}

- (NSMutableArray *)allLabelStatus {
    if (!_allLabelStatus) {
        _allLabelStatus = [NSMutableArray arrayWithArray:@[@0, @0, @0, @0, @0, @0]];
    }
    return _allLabelStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionLabel.text = kVersion_App;
 
    // 恢复存储数据
    NSArray *recoveryCode = [self recoveryBlueDeviceStatus];
    
    if (recoveryCode.count > 0) {
        self.offOnAndStatusbtnSendCode = [recoveryCode mutableCopy];
        // 恢复开关按钮对应位
        _whickLamp = [self.offOnAndStatusbtnSendCode[3] integerValue];
        // 恢复开关按钮状态
        [self recoveryOnOffBtnValueWithIntegerArray:recoveryCode];
        // 恢复模式按钮状态
        [self recoveryModelBtnValueWithIntegerArray:recoveryCode];
        
        // 解析数据第三位，发送数据
        [self parsedWithIntegerArray:recoveryCode];
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    // 针对不同手机，修改顶部距离
    if (screenHeight == 375) {
        self.stackViewTopCons.constant = 84;
    } else if (screenHeight == 414){
        self.stackViewTopCons.constant = 100;
    } else if (screenHeight > 414) {
        self.stackViewTopCons.constant = 180;
        self.logoIvTopCons.constant = 60;
    } else {
        self.stackViewTopCons.constant = 76;
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    // 由于跳到模式三的时候，offOnAndStatusbtnSendCode[3] 会变成模式四，这样回显状态会不准确
    // 所以offOnAndStatusbtnSendCode的model按钮位置替换为allLabelStatus的值
    for (int i = 0; i < 6; i++) {
        self.offOnAndStatusbtnSendCode[i + 4] = self.allLabelStatus[i];
    }
    
    // 界面消失之前把发送的数组第四个字节，数组第三位改为亮了几个灯的值
    self.offOnAndStatusbtnSendCode[3] = @(_whickLamp);
    [self saveBlueDeviceStatusWithCode:self.offOnAndStatusbtnSendCode];
    
    [super viewWillDisappear:animated];
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
    
    JHLog(@"SwitchViewController销毁");
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
    JHLog(@"%lu", (unsigned long)characteristic.properties);
    
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        
    }else{
        JHLog(@"该字段不可写！");
    }
    
    
}

// 设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

// 取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

/**
 *  改变模式，修改发送的数据
 *
 *  @param index 索引
 *  @param num   修改前的状态
 */
- (void)changeStatusWithArrayIndex:(NSInteger)index Num:(NSInteger)num {
    
    num += 1;
    
    // 大于等于4重置
    if (num >= self.statusHex.count - 1) {
        num = 0;
    }
    
    // 保存当前状态
    self.allLabelStatus[index] = @(num);
    // 修改发送数据的值
    self.offOnAndStatusbtnSendCode[4 + index] = self.statusHex[num];
}

/**
 *  检测设备是否锁定
 *
 */
- (BOOL) checkLock:(char*)codes {
    char lockFlag[] = {0x00};
    lockFlag[0] = codes[2];
    NSString *lock = [[NSString alloc] initWithData:[NSData dataWithBytes:lockFlag length:1]  encoding:NSUTF8StringEncoding];
    if ([lock isEqualToString: @"\x01"]) {
        return YES;
    }
    
    return NO;
}


/**
 *  CRC校验
 *
 */
- (BOOL) checkCRC:(char*)codes {
    // 计算CRC
    char ch[] = {0x00};
    for (int i = 0; i < 10; i++) {
        ch[0] += codes[i];
    }
    
    // 返回的CRC
    char backch[] = {0x00};
    backch[0] = codes[10];
    
    NSString *calCRC = [[NSString alloc] initWithData:[NSData dataWithBytes:ch length:1]  encoding:NSUTF8StringEncoding];
    NSString *backCRC = [[NSString alloc] initWithData:[NSData dataWithBytes:backch length:1]  encoding:NSUTF8StringEncoding];
    
    // 比较CRC
    return [calCRC isEqualToString:backCRC];
}





/**
 *  发送码值计算
 *
 */
- (NSData *) convertCode:(char*)codes {
    char ch = 0;
    for (int i = 0; i < 10; i++) {
        ch += codes[i];
    }
    
    codes[10] = ch;
    JHLog(@"%zd", [NSData dataWithBytes:codes length:kDataLength].length);
    JHLog(@"%@", [[NSString alloc] initWithData:[NSData dataWithBytes:codes length:kDataLength]  encoding:NSUTF8StringEncoding]);
    return [NSData dataWithBytes:codes length:kDataLength];
}

/**
 *  把发送的给蓝牙设备的数据从integer数组转为char数据，并把char数据转为NSData
 *
 *  @param integerArray 转换数组
 *  @param isSave       是否保存
 *
 *  @return 转换后数据
 */
- (NSData *) converToCharArrayWithIntegerArray:(NSMutableArray *) integerArray isSave:(BOOL)isSave {
    
    char charArray[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00};
    
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
    
    if (isSave) {
        // 保存发送数值到偏好设置
        [self saveBlueDeviceStatusWithCode:integerArray];
    }

    return [NSData dataWithBytes:charArray length:integerArray.count];
}




/**
 *  保存蓝牙设备的状态，即每个按钮按下的状态
 *
 *  @param integerArray 按钮保存的状态，即发送给设备的数组
 */
- (void) saveBlueDeviceStatusWithCode:(NSMutableArray *)integerArray {

    // 1.获取NSUserDefaults对象
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    // 2.保存数据
    [defaults setObject:integerArray forKey:@"offOnAndStatusbtnSendCode"];

    // 3.强制让数据立刻保存
    [defaults synchronize];
}

/**
 *  从偏好设置中恢复蓝牙设备的状态，即每个按钮按下的状态
 *
 */
- (NSArray *) recoveryBlueDeviceStatus {
    // 1.获取NSUserDefaults对象
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSArray *integerArray = [defaults objectForKey:@"offOnAndStatusbtnSendCode"];
    
    return integerArray;
}

/**
 *  根据数组恢复开关按钮状态
 *
 */
- (void)recoveryOnOffBtnValueWithIntegerArray:(NSArray *)integerArray {
    
    NSInteger onOffValue = [integerArray[3] integerValue];
    JHLog(@"%zd", (onOffValue / 1) % 2);
    
    // 判断灯1
    self.onOffBtn1.selected = ((onOffValue / 1) % 2) == 1 ? YES : NO;
    self.offFlay1.highlighted = ((onOffValue / 1) % 2) == 1 ? YES : NO;
    self.modelBtn1.selected = ((onOffValue / 1) % 2) == 1 ? YES : NO;
    
    // 判断灯2
    self.onOffBtn2.selected = ((onOffValue / 2) % 2) == 1 ? YES : NO;
    self.offFlay2.highlighted = ((onOffValue / 2) % 2) == 1 ? YES : NO;
    self.modelBtn2.selected = ((onOffValue / 2) % 2) == 1 ? YES : NO;
    
    // 判断灯3
    self.onOffBtn3.selected = ((onOffValue / 4) % 2) == 1 ? YES : NO;
    self.offFlay3.highlighted = ((onOffValue / 4) % 2) == 1 ? YES : NO;
    self.modelBtn3.selected = ((onOffValue / 4) % 2) == 1 ? YES : NO;
    
    // 判断灯4
    self.onOffBtn4.selected = ((onOffValue / 8) % 2) == 1 ? YES : NO;
    self.offFlay4.highlighted = ((onOffValue / 8) % 2) == 1 ? YES : NO;
    self.modelBtn4.selected = ((onOffValue / 8) % 2) == 1 ? YES : NO;
    
    // 判断灯5
    self.onOffBtn5.selected = ((onOffValue / 16) % 2) == 1 ? YES : NO;
    self.offFlay5.highlighted = ((onOffValue / 16) % 2) == 1 ? YES : NO;
    self.modelBtn5.selected = ((onOffValue / 16) % 2) == 1 ? YES : NO;
    
    // 判断灯6
    self.onOffBtn6.selected = ((onOffValue / 32) % 2) == 1 ? YES : NO;
    self.offFlay6.highlighted = ((onOffValue / 32) % 2) == 1 ? YES : NO;
    self.modelBtn6.selected = ((onOffValue / 32) % 2) == 1 ? YES : NO;


    
}

/**
 *  根据数组恢复Model按钮状态
 */
- (void) recoveryModelBtnValueWithIntegerArray:(NSArray *)integerArray {
    
    // 恢复每个按钮的模式
    for (int i = 0; i < 6; i++) {
        self.allLabelStatus[i] = integerArray[i + 4];
    }

    // 根据存储的模式判断高亮
    switch ([self.allLabelStatus[0] integerValue]) {
        case kStrobe:
            self.strobeIv1.highlighted = YES;
            break;
        case kFlash:
            self.flashIv1.highlighted = YES;
            break;
        case kMomenyary:
            self.momentaryIv1.highlighted = YES;
            break;
        default:
            break;
    }
    
    // 根据存储的模式判断高亮
    switch ([self.allLabelStatus[1] integerValue]) {
        case kStrobe:
            self.strobeIv2.highlighted = YES;
            break;
        case kFlash:
            self.flashIv2.highlighted = YES;
            break;
        case kMomenyary:
            self.momentaryIv2.highlighted = YES;
            break;
        default:
            break;
    }
    
    // 根据存储的模式判断高亮
    switch ([self.allLabelStatus[2] integerValue]) {
        case kStrobe:
            self.strobeIv3.highlighted = YES;
            break;
        case kFlash:
            self.flashIv3.highlighted = YES;
            break;
        case kMomenyary:
            self.momentaryIv3.highlighted = YES;
            break;
        default:
            break;
    }
    
    // 根据存储的模式判断高亮
    switch ([self.allLabelStatus[3] integerValue]) {
        case kStrobe:
            self.strobeIv4.highlighted = YES;
            break;
        case kFlash:
            self.flashIv4.highlighted = YES;
            break;
        case kMomenyary:
            self.momentaryIv4.highlighted = YES;
            break;
        default:
            break;
    }
    
    // 根据存储的模式判断高亮
    switch ([self.allLabelStatus[4] integerValue]) {
        case kStrobe:
            self.strobeIv5.highlighted = YES;
            break;
        case kFlash:
            self.flashIv5.highlighted = YES;
            break;
        case kMomenyary:
            self.momentaryIv5.highlighted = YES;
            break;
        default:
            break;
    }
    
    // 根据存储的模式判断高亮
    switch ([self.allLabelStatus[5] integerValue]) {
        case kStrobe:
            self.strobeIv6.highlighted = YES;
            break;
        case kFlash:
            self.flashIv6.highlighted = YES;
            break;
        case kMomenyary:
            self.momentaryIv6.highlighted = YES;
            break;
        default:
            break;
    }
}

/**
 *  解析数组，回显数据时每打开一个灯，发送一次数据
 *
 *  @param integerArray 数据
 */
- (void) parsedWithIntegerArray:(NSArray *)integerArray {
    NSInteger onOffValue = [integerArray[3] integerValue];
    
    // 1+2+4+8+16+32
    // 灯1 打开就发送灯1打开数据
    if ((onOffValue / 1) % 2 == 1) {
        NSMutableArray *temp = [integerArray mutableCopy];
        temp[3] = @1;
        [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:temp isSave:NO]];
    }
    
    // 灯2 打开就发送灯2打开数据
    if ((onOffValue / 2) % 2 == 1) {
        NSMutableArray *temp = [integerArray mutableCopy];
        temp[3] = @3;
        [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:temp isSave:NO]];
    }
    

    // 灯3 打开就发送灯3打开数据
    if ((onOffValue / 4) % 2 == 1) {
        NSMutableArray *temp = [integerArray mutableCopy];
        temp[3] = @7;
        [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:temp isSave:NO]];
    }
    
    // 灯4 打开就发送灯4打开数据
    if ((onOffValue / 8) % 2 == 1) {
        NSMutableArray *temp = [integerArray mutableCopy];
        temp[3] = @15;
        [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:temp isSave:NO]];
    }
    

    // 灯5 打开就发送灯5打开数据
    if ((onOffValue / 16) % 2 == 1) {
        NSMutableArray *temp = [integerArray mutableCopy];
        temp[3] = @31;
        [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:temp isSave:NO]];
    }
    
    // 灯6 打开就发送灯6打开数据
    if ((onOffValue / 32) % 2 == 1) {
        NSMutableArray *temp = [integerArray mutableCopy];
        temp[3] = @63;
        [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:temp isSave:NO]];
    }
}



- (IBAction)backClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 按钮点击处理
// 灯开关松开时触发
- (IBAction)onOffBtnTouchUpInside:(UIButton *)btn {
    /**
     *  由于在模式三的时候开关是：按下开，松开关，所以需要松开立刻改变按钮状态
     */
    switch (btn.tag - 10000) {
        case 1:
            if ([self.allLabelStatus[0] integerValue] == kMomenyary) {
                
                // 松开肯定是关闭
                _whickLamp -= 1;
                
                // 因为松开时是操作特定的位，需要传输操作位的码值
                // 每个开关对应的码值，用于模式三松开按钮时，关闭对应开关发送的码值
                self.offOnAndStatusbtnSendCode[3] = @1;
                // 修改开关状态
                btn.selected = NO;
                
                self.offFlay1.highlighted = btn.isSelected;
                
                // 修改model按钮
                self.modelBtn1.selected = btn.isSelected;
                
                // 修改发送数据，改为关
                self.offOnAndStatusbtnSendCode[4 + 0] = self.statusHex[kMomenyary + 1];
                
                // 发送数据
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];

            }
            
            
            break;
        case 2:
            if ([self.allLabelStatus[1] integerValue] == kMomenyary) {
                
                _whickLamp -= 2;
                self.offOnAndStatusbtnSendCode[3] = @2;
                
                btn.selected = NO;
                
                self.offFlay2.highlighted = btn.isSelected;
                
                self.modelBtn2.selected = btn.isSelected;
                
                self.offOnAndStatusbtnSendCode[4 + 1] = self.statusHex[kMomenyary + 1];
            
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            }
            
            break;
        case 3:
            if ([self.allLabelStatus[2] integerValue] == kMomenyary) {
                _whickLamp -= 4;
                self.offOnAndStatusbtnSendCode[3] = @4;
                
                btn.selected = NO;
                
                self.offFlay3.highlighted = btn.isSelected;
                
                self.modelBtn3.selected = btn.isSelected;
                
                self.offOnAndStatusbtnSendCode[4 + 2] = self.statusHex[kMomenyary + 1];
                
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            }
            break;
        case 4:
            if ([self.allLabelStatus[3] integerValue] == kMomenyary) {
                _whickLamp -= 8;
                self.offOnAndStatusbtnSendCode[3] = @8;
                
                btn.selected = NO;
                
                self.offFlay4.highlighted = btn.isSelected;
                
                self.modelBtn4.selected = btn.isSelected;
                
                self.offOnAndStatusbtnSendCode[4 + 3] = self.statusHex[kMomenyary + 1];
                
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            }
            break;
        case 5:
            if ([self.allLabelStatus[4] integerValue] == kMomenyary) {
                _whickLamp -= 16;
                self.offOnAndStatusbtnSendCode[3] = @16;
                
                btn.selected = NO;
                
                self.offFlay5.highlighted = btn.isSelected;
                
                self.modelBtn5.selected = btn.isSelected;
                
                self.offOnAndStatusbtnSendCode[4 + 4] = self.statusHex[kMomenyary + 1];
                
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            }
            break;
        case 6:
            if ([self.allLabelStatus[5] integerValue] == kMomenyary) {
                _whickLamp -= 32;
                self.offOnAndStatusbtnSendCode[3] = @32;
                
                btn.selected = NO;
                
                self.offFlay6.highlighted = btn.isSelected;
                
                self.modelBtn6.selected = btn.isSelected;
                
                self.offOnAndStatusbtnSendCode[4 + 5] = self.statusHex[kMomenyary + 1];
                
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            }
            break;
        default:
            break;
    }
}

// 灯开关按下时触发
- (IBAction)onOffBtnTouchDown:(UIButton *)btn {
    // 判断标识位
    switch (btn.tag - 10000) {
        case 1:
            // 根据是否选中，修改发送数据
            if (btn.selected) {
                // 关灯是操作具体那个开关
                _whickLamp -= 1;
                self.offOnAndStatusbtnSendCode[3] = @1;
                
                self.offOnAndStatusbtnSendCode[4 + 0] = self.statusHex[kMomenyary + 1];
                
                // 判断是否模式三
                if ([self.allLabelStatus[0] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay1.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn1.selected = btn.isSelected;
                    
                    // 灯对应的模式位默认是0x01，不用修改
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay1.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn1.selected = btn.highlighted;
                }
                
            } else {
                // 开灯是把所有打开的灯的值加起来
                _whickLamp += 1;
                self.offOnAndStatusbtnSendCode[3] = @(_whickLamp);
                
                
                // 判断是否模式三
                if ([self.allLabelStatus[0] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay1.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn1.selected = btn.isSelected;
                    
                    // 恢复之前的状态
                    self.offOnAndStatusbtnSendCode[4 + 0] = self.statusHex[[self.allLabelStatus[0] integerValue]];
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay1.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn1.selected = btn.highlighted;
                    
                    // 修改发送数据
                    self.offOnAndStatusbtnSendCode[4 + 0] = self.statusHex[kMomenyary];
                }
            }
            
            // 发送数据
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            break;
        case 2:
            
            // 根据是否选中，修改发送数据
            if (btn.selected) {
                // 关灯是操作具体那个开关
                _whickLamp -= 2;
                self.offOnAndStatusbtnSendCode[3] = @2;
                
                self.offOnAndStatusbtnSendCode[4 + 1] = self.statusHex[kMomenyary + 1];
                
                // 判断是否模式三
                if ([self.allLabelStatus[1] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay2.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn2.selected = btn.isSelected;
                    
                    // 灯对应的模式位默认是0x01，不用修改
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay2.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn2.selected = btn.highlighted;
                }
                
            } else {
                // 开灯是把所有打开的灯的值加起来
                _whickLamp += 2;
                self.offOnAndStatusbtnSendCode[3] = @(_whickLamp);
                
                
                // 判断是否模式三
                if ([self.allLabelStatus[1] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay2.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn2.selected = btn.isSelected;
                    
                    // 恢复之前的状态
                    self.offOnAndStatusbtnSendCode[4 + 1] = self.statusHex[[self.allLabelStatus[1] integerValue]];
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay2.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn2.selected = btn.highlighted;
                    
                    // 修改发送数据
                    self.offOnAndStatusbtnSendCode[4 + 1] = self.statusHex[kMomenyary];
                }
            }
            
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            break;
        case 3:
            
            
            // 根据是否选中，修改发送数据
            if (btn.selected) {
                // 关灯是操作具体那个开关
                _whickLamp -= 4;
                self.offOnAndStatusbtnSendCode[3] = @4;
                
                self.offOnAndStatusbtnSendCode[4 + 2] = self.statusHex[kMomenyary + 1];
                
                // 判断是否模式三
                if ([self.allLabelStatus[2] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay3.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn3.selected = btn.isSelected;
                    
                    // 灯对应的模式位默认是0x01，不用修改
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay3.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn3.selected = btn.highlighted;
                }
                
            } else {
                // 开灯是把所有打开的灯的值加起来
                _whickLamp += 4;
                self.offOnAndStatusbtnSendCode[3] = @(_whickLamp);
                
                
                // 判断是否模式三
                if ([self.allLabelStatus[2] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay3.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn3.selected = btn.isSelected;
                    
                    // 恢复之前的状态
                    self.offOnAndStatusbtnSendCode[4 + 2] = self.statusHex[[self.allLabelStatus[2] integerValue]];
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay3.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn3.selected = btn.highlighted;
                    
                    // 修改发送数据
                    self.offOnAndStatusbtnSendCode[4 + 2] = self.statusHex[kMomenyary];
                }
            }
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            break;
        case 4:
            
            
            // 根据是否选中，修改发送数据
            if (btn.selected) {
                // 关灯是操作具体那个开关
                _whickLamp -= 8;
                self.offOnAndStatusbtnSendCode[3] = @8;
                
                self.offOnAndStatusbtnSendCode[4 + 3] = self.statusHex[kMomenyary + 1];
                
                // 判断是否模式三
                if ([self.allLabelStatus[3] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay4.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn4.selected = btn.isSelected;
                    
                    // 灯对应的模式位默认是0x01，不用修改
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay4.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn4.selected = btn.highlighted;
                }
                
            } else {
                // 开灯是把所有打开的灯的值加起来
                _whickLamp += 8;
                self.offOnAndStatusbtnSendCode[3] = @(_whickLamp);
                
                
                // 判断是否模式三
                if ([self.allLabelStatus[3] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay4.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn4.selected = btn.isSelected;
                    
                    // 恢复之前的状态
                    self.offOnAndStatusbtnSendCode[4 + 3] = self.statusHex[[self.allLabelStatus[3] integerValue]];
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay4.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn4.selected = btn.highlighted;
                    
                    // 修改发送数据
                    self.offOnAndStatusbtnSendCode[4 + 3] = self.statusHex[kMomenyary];
                }
            }
            
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            break;
        case 5:
            
            // 根据是否选中，修改发送数据
            if (btn.selected) {
                // 关灯是操作具体那个开关
                _whickLamp -= 16;
                self.offOnAndStatusbtnSendCode[3] = @16;
                
                self.offOnAndStatusbtnSendCode[4 + 4] = self.statusHex[kMomenyary + 1];
                
                // 判断是否模式三
                if ([self.allLabelStatus[4] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay5.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn5.selected = btn.isSelected;
                    
                    // 灯对应的模式位默认是0x01，不用修改
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay5.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn5.selected = btn.highlighted;
                }
                
            } else {
                // 开灯是把所有打开的灯的值加起来
                _whickLamp += 16;
                self.offOnAndStatusbtnSendCode[3] = @(_whickLamp);
                
                
                // 判断是否模式三
                if ([self.allLabelStatus[4] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay5.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn5.selected = btn.isSelected;
                    
                    // 恢复之前的状态
                    self.offOnAndStatusbtnSendCode[4 + 4] = self.statusHex[[self.allLabelStatus[4] integerValue]];
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay5.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn5.selected = btn.highlighted;
                    
                    // 修改发送数据
                    self.offOnAndStatusbtnSendCode[4 + 4] = self.statusHex[kMomenyary];
                }
            }
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            break;
        case 6:
            
            // 根据是否选中，修改发送数据
            if (btn.selected) {
                // 关灯是操作具体那个开关
                _whickLamp -= 32;
                self.offOnAndStatusbtnSendCode[3] = @32;
                
                self.offOnAndStatusbtnSendCode[4 + 5] = self.statusHex[kMomenyary + 1];
                
                // 判断是否模式三
                if ([self.allLabelStatus[5] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay6.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn6.selected = btn.isSelected;
                    
                    // 灯对应的模式位默认是0x01，不用修改
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay6.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn6.selected = btn.highlighted;
                }
                
            } else {
                // 开灯是把所有打开的灯的值加起来
                _whickLamp += 32;
                self.offOnAndStatusbtnSendCode[3] = @(_whickLamp);
                
                
                // 判断是否模式三
                if ([self.allLabelStatus[5] integerValue] != kMomenyary) {
                    // 不是模式三
                    
                    // 修改开关是否选中
                    btn.selected = !btn.selected;
                    // 修改开关状态标识
                    self.offFlay6.highlighted = btn.isSelected;
                    // 修改model按钮
                    self.modelBtn6.selected = btn.isSelected;
                    
                    // 恢复之前的状态
                    self.offOnAndStatusbtnSendCode[4 + 5] = self.statusHex[[self.allLabelStatus[5] integerValue]];
                    
                } else {
                    // 是模式三，是根据开关高亮来修改标识和Model按钮
                    if (!btn.highlighted) {
                        btn.selected = !btn.selected;
                    }
                    
                    self.offFlay6.highlighted = btn.highlighted;
                    
                    // 修改model按钮
                    self.modelBtn6.selected = btn.highlighted;
                    
                    // 修改发送数据
                    self.offOnAndStatusbtnSendCode[4 + 5] = self.statusHex[kMomenyary];
                }
            }
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
            break;
        default:
            break;
    }
}

- (IBAction)modelBtnClick:(UIButton *)btn {
    // 修改模式
    switch (btn.tag - 20000) {
        case 1:
            
            // 改变模式，修改发送的数据
            [self changeStatusWithArrayIndex:0 Num:[self.allLabelStatus[0] integerValue]];
            // 修改模式的开关位
            self.offOnAndStatusbtnSendCode[3] = @1;
            
            // 改变模式图片
            // 全不高亮
            self.strobeIv1.highlighted = NO;
            self.flashIv1.highlighted = NO;
            self.momentaryIv1.highlighted = NO;
            // 根据存储的模式判断高亮
            switch ([self.allLabelStatus[0] integerValue]) {
                case kStrobe:
                    self.strobeIv1.highlighted = YES;
                    break;
                case kFlash:
                    self.flashIv1.highlighted = YES;
                    break;
                case kMomenyary:
                    self.momentaryIv1.highlighted = YES;
                    break;
                default:
                    break;
            }
            
            // 当开关开着才发送数据
            if (self.onOffBtn1.isSelected) {
                
                // 是模式3，立刻关闭灯开关
                if ([self.allLabelStatus[0] integerValue] == kMomenyary) {
                    [self onOffBtnTouchDown:self.onOffBtn1];
                } else {
                    // 其他模式正常发送数据
                    [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
                }
            }
            
            // 保存发送数值到偏好设置
            [self saveBlueDeviceStatusWithCode:self.offOnAndStatusbtnSendCode];
            
            break;
        case 2:
            
            [self changeStatusWithArrayIndex:1 Num:[self.allLabelStatus[1] integerValue]];

            // 修改模式的开关位
            self.offOnAndStatusbtnSendCode[3] = @2;
            
            // 改变模式图片
            // 全不高亮
            self.strobeIv2.highlighted = NO;
            self.flashIv2.highlighted = NO;
            self.momentaryIv2.highlighted = NO;
            // 根据存储的模式判断高亮
            switch ([self.allLabelStatus[1] integerValue]) {
                case kStrobe:
                    self.strobeIv2.highlighted = YES;
                    break;
                case kFlash:
                    self.flashIv2.highlighted = YES;
                    break;
                case kMomenyary:
                    self.momentaryIv2.highlighted = YES;
                    break;
                default:
                    break;
            }
            
            
            // 当开关开着才发送数据
            if (self.onOffBtn2.isSelected) {
                
                // 是模式3，立刻关闭灯开关
                if ([self.allLabelStatus[1] integerValue] == kMomenyary) {
                    [self onOffBtnTouchDown:self.onOffBtn2];
                } else {
                    // 其他模式正常发送数据
                    [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
                }
            }
            
            // 保存发送数值到偏好设置
            [self saveBlueDeviceStatusWithCode:self.offOnAndStatusbtnSendCode];
            
            break;
        case 3:
            
            [self changeStatusWithArrayIndex:2 Num:[self.allLabelStatus[2] integerValue]];

            // 修改模式的开关位
            self.offOnAndStatusbtnSendCode[3] = @4;
            
            // 改变模式图片
            // 全不高亮
            self.strobeIv3.highlighted = NO;
            self.flashIv3.highlighted = NO;
            self.momentaryIv3.highlighted = NO;
            // 根据存储的模式判断高亮
            switch ([self.allLabelStatus[2] integerValue]) {
                case kStrobe:
                    self.strobeIv3.highlighted = YES;
                    break;
                case kFlash:
                    self.flashIv3.highlighted = YES;
                    break;
                case kMomenyary:
                    self.momentaryIv3.highlighted = YES;
                    break;
                default:
                    break;
            }
            
            // 当开关开着才发送数据
            if (self.onOffBtn3.isSelected) {
                
                // 是模式3，立刻关闭灯开关
                if ([self.allLabelStatus[2] integerValue] == kMomenyary) {
                    [self onOffBtnTouchDown:self.onOffBtn3];
                } else {
                    // 其他模式正常发送数据
                    [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
                }
            }
            
            // 保存发送数值到偏好设置
            [self saveBlueDeviceStatusWithCode:self.offOnAndStatusbtnSendCode];
            
            break;
        case 4:
            
            
            [self changeStatusWithArrayIndex:3 Num:[self.allLabelStatus[3] integerValue]];

            // 修改模式的开关位
            self.offOnAndStatusbtnSendCode[3] = @8;
            
            // 改变模式图片
            // 全不高亮
            self.strobeIv4.highlighted = NO;
            self.flashIv4.highlighted = NO;
            self.momentaryIv4.highlighted = NO;
            // 根据存储的模式判断高亮
            switch ([self.allLabelStatus[3] integerValue]) {
                case kStrobe:
                    self.strobeIv4.highlighted = YES;
                    break;
                case kFlash:
                    self.flashIv4.highlighted = YES;
                    break;
                case kMomenyary:
                    self.momentaryIv4.highlighted = YES;
                    break;
                default:
                    break;
            }
            
            // 当开关开着才发送数据
            if (self.onOffBtn4.isSelected) {
                
                // 是模式3，立刻关闭灯开关
                if ([self.allLabelStatus[3] integerValue] == kMomenyary) {
                    [self onOffBtnTouchDown:self.onOffBtn4];
                } else {
                    // 其他模式正常发送数据
                    [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
                }
            }
            
            // 保存发送数值到偏好设置
            [self saveBlueDeviceStatusWithCode:self.offOnAndStatusbtnSendCode];
            
            break;
        case 5:
            [self changeStatusWithArrayIndex:4 Num:[self.allLabelStatus[4] integerValue]];

            // 修改模式的开关位
            self.offOnAndStatusbtnSendCode[3] = @16;
            
            // 改变模式图片
            // 全不高亮
            self.strobeIv5.highlighted = NO;
            self.flashIv5.highlighted = NO;
            self.momentaryIv5.highlighted = NO;
            // 根据存储的模式判断高亮
            switch ([self.allLabelStatus[4] integerValue]) {
                case kStrobe:
                    self.strobeIv5.highlighted = YES;
                    break;
                case kFlash:
                    self.flashIv5.highlighted = YES;
                    break;
                case kMomenyary:
                    self.momentaryIv5.highlighted = YES;
                    break;
                default:
                    break;
            }
            
            // 当开关开着才发送数据
            if (self.onOffBtn5.isSelected) {
                
                // 是模式3，立刻关闭灯开关
                if ([self.allLabelStatus[4] integerValue] == kMomenyary) {
                    [self onOffBtnTouchDown:self.onOffBtn5];
                } else {
                    // 其他模式正常发送数据
                    [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
                }
            }
            
            // 保存发送数值到偏好设置
            [self saveBlueDeviceStatusWithCode:self.offOnAndStatusbtnSendCode];
            
            break;
        case 6:
            [self changeStatusWithArrayIndex:5 Num:[self.allLabelStatus[5] integerValue]];

            // 修改模式的开关位
            self.offOnAndStatusbtnSendCode[3] = @32;
            
            // 改变模式图片
            // 全不高亮
            self.strobeIv6.highlighted = NO;
            self.flashIv6.highlighted = NO;
            self.momentaryIv6.highlighted = NO;
            // 根据存储的模式判断高亮
            switch ([self.allLabelStatus[5] integerValue]) {
                case kStrobe:
                    self.strobeIv6.highlighted = YES;
                    break;
                case kFlash:
                    self.flashIv6.highlighted = YES;
                    break;
                case kMomenyary:
                    self.momentaryIv6.highlighted = YES;
                    break;
                default:
                    break;
            }
            
            // 当开关开着才发送数据
            if (self.onOffBtn6.isSelected) {
                
                // 是模式3，立刻关闭灯开关
                if ([self.allLabelStatus[5] integerValue] == kMomenyary) {
                    [self onOffBtnTouchDown:self.onOffBtn6];
                } else {
                    // 其他模式正常发送数据
                    [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
                }
            }
            
            // 保存发送数值到偏好设置
            [self saveBlueDeviceStatusWithCode:self.offOnAndStatusbtnSendCode];
            
            break;
        default:
            break;
    }
}

- (IBAction)lockSwichClick:(UISwitch *)switchBtn {
    if (switchBtn.isOn) {
        [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:lockSendCode]];
    } else {
        [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:unlockSendCode]];
    }
}


#pragma mark - CBPeripheralDelegate
/*
 扫描到Services
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        JHLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
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
        JHLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    //遍历服务中的特征
    CBUUID *serviceUUID=[CBUUID UUIDWithString:kStartServiceUUID];
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kStartCharacteristicUUID];
    CBUUID *notifyCharacteristicUUID=[CBUUID UUIDWithString:kStartNotifyCharacteristicUUID];
    if ([service.UUID isEqual:serviceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:characteristicUUID]) {
                
                
                [self writePeripheral:peripheral characteristic:characteristic value:[self startCode]];
                self.FFFAcharacteristic = characteristic;
                
                // 发送回显数据
                [self writePeripheral:peripheral characteristic:self.FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.offOnAndStatusbtnSendCode isSave:YES]];
                
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
    
    JHLog(@"收到特征更新通知...");
    if (error) {
        JHLog(@"更新通知状态时发生错误，错误信息：%@",error.localizedDescription);
    }
    
    // 给特征值设置新的值
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kStartNotifyCharacteristicUUID];
    if ([characteristic.UUID isEqual:characteristicUUID]) {
        if (characteristic.isNotifying) {
            if (characteristic.properties == CBCharacteristicPropertyNotify) {
                JHLog(@"已订阅特征通知.");
                return;
            }else if (characteristic.properties == CBCharacteristicPropertyRead) {
                //从外围设备读取新值,调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
                [peripheral readValueForCharacteristic:characteristic];
            }
            
        }else{
            JHLog(@"停止已停止.");
        }
    }
}


/*
 更新特征值后（调用readValueForCharacteristic:方法或者外围设备在订阅后更新特征值都会调用此代理方法）
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        JHLog(@"更新特征值时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    CBUUID *notifyCharacteristicUUID=[CBUUID UUIDWithString:kStartNotifyCharacteristicUUID];
    JHLog(@"%@", characteristic.UUID.UUIDString);
    if ([characteristic.UUID isEqual:notifyCharacteristicUUID]) {
        
        NSString *backDataString = [[NSString alloc] initWithBytes:[characteristic.value bytes] length:kDataLength encoding:NSUTF8StringEncoding];
        if (backDataString) {
            //打印出characteristic的UUID和值
            //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
            
            JHLog(@"返回的数据长度->%zd，值->%@", [characteristic.value length], backDataString);
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
            BOOL lockFlag = [self checkLock:backCode];
            if (lockFlag) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"设备已经被锁定" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                [alertView show];
//                return;
            }
        }else{
            JHLog(@"未发现特征值.");
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
        JHLog(@"说明发送成功，characteristic.uuid为：%@",[characteristic.UUID UUIDString]);
        [self.mPeripheral readValueForCharacteristic:self.FFFAcharacteristic];
    }else{
        JHLog(@"发送失败了啊！characteristic.uuid为：%@",[characteristic.UUID UUIDString]);
    }
    
}



//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    JHLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        JHLog(@"Descriptor uuid:%@",d.UUID);
    }
    
}
//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    JHLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}




@end
