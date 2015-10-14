//
//  OperationViewController.m
//  BleDemo
//
//  Created by piglikeyoung on 15/10/11.
//  Copyright © 2015年 liuyanwei. All rights reserved.
//

#import "OperationViewController.h"

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

// 开关和模式按钮发送的数据
static char offOnAndStatusbtnSendCode[] = {0x4c, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01 , 0x01, 0x01, 0x00};

// 锁定设备数据
static char lockSendCode[] = {0x4d, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00};
// 解锁设备数据
static char unlockSendCode[] = {0x4d, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00};

// 模式三
static const NSInteger kMomenyary = 2;

@interface OperationViewController ()<CBPeripheralDelegate>

@property (nonatomic, strong) CBCharacteristic *FFFAcharacteristic;
@property (nonatomic, strong) CBCharacteristic *FFFBcharacteristic;

// 记录哪盏灯亮着（控制的是全部灯 则该字节为 1+2+4+8+16+32；控制第一个灯	则该字节为1）
@property (nonatomic, assign) NSInteger whickLamp;

// 记录label显示的字
@property (nonatomic, strong) NSArray *statusTexts;
// 记录label要发送的16进制值
@property (nonatomic, strong) NSArray *statusHex;
// 记录label的当前状态
@property (nonatomic, strong) NSMutableArray *allLabelStatus;

@property (weak, nonatomic) IBOutlet UIButton *btnOnOff1;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOff2;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOff3;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOff4;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOff5;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOff6;

@property (weak, nonatomic) IBOutlet UIButton *btnStatus1;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus2;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus3;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus4;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus5;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus6;

@property (weak, nonatomic) IBOutlet UILabel *labelStatus1;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus2;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus3;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus4;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus5;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus6;

@property (weak, nonatomic) IBOutlet UISwitch *lockSwichBtn;

@end

@implementation OperationViewController

- (NSArray *)statusHex {
    if (!_statusHex) {
        _statusHex = @[@0x01, @0x02, @0x03, @0x04];
    }
    return _statusHex;
}

- (NSArray *)statusTexts {
    if (!_statusTexts) {
        _statusTexts = @[@"STROBE", @"FLASH", @"MOMENYARY", @"关"];
    }
    return _statusTexts;
}

- (NSMutableArray *)allLabelStatus {
    if (!_allLabelStatus) {
        _allLabelStatus = [NSMutableArray arrayWithArray:@[@0, @0, @0, @0, @0, @0]];
    }
    return _allLabelStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _mPeripheral.delegate = self;
    [_mPeripheral discoverServices:nil];
}

- (void)dealloc {
    if (self.mPeripheral) {
        self.mPeripheral = nil;
    }
}

- (BOOL) shouldAutorotate{
    
    return YES;
    
}



- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

#pragma mark - 按钮点击处理
// 松开触发
- (IBAction)offOnbtnClick:(UIButton *)btn {

    switch (btn.tag) {
        case 10001:
            if ([self.allLabelStatus[0] integerValue] == kMomenyary) {
                
                // 当是模式3的时候，松手变成模式“关”
                [self changeStatusWithArrayIndex:0 Num:[self.allLabelStatus[0] integerValue]];
                // 修改显示的文字
                self.labelStatus1.text = self.statusTexts[[self.allLabelStatus[0] integerValue]];
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            
            
            break;
        case 10002:
            if ([self.allLabelStatus[1] integerValue] == kMomenyary) {
                // 当是模式3的时候，松手变成模式“关”
                [self changeStatusWithArrayIndex:1 Num:[self.allLabelStatus[1] integerValue]];
                // 修改显示的文字
                self.labelStatus1.text = self.statusTexts[[self.allLabelStatus[1] integerValue]];
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            break;
        case 10003:
            if ([self.allLabelStatus[2] integerValue] == kMomenyary) {
                // 当是模式3的时候，松手变成模式“关”
                [self changeStatusWithArrayIndex:2 Num:[self.allLabelStatus[2] integerValue]];
                // 修改显示的文字
                self.labelStatus1.text = self.statusTexts[[self.allLabelStatus[2] integerValue]];
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            break;
        case 10004:
            if ([self.allLabelStatus[3] integerValue] == kMomenyary) {
                // 当是模式3的时候，松手变成模式“关”
                [self changeStatusWithArrayIndex:3 Num:[self.allLabelStatus[3] integerValue]];
                // 修改显示的文字
                self.labelStatus1.text = self.statusTexts[[self.allLabelStatus[3] integerValue]];
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            break;
        case 10005:
            if ([self.allLabelStatus[4] integerValue] == kMomenyary) {
                // 当是模式3的时候，松手变成模式“关”
                [self changeStatusWithArrayIndex:4 Num:[self.allLabelStatus[4] integerValue]];
                // 修改显示的文字
                self.labelStatus1.text = self.statusTexts[[self.allLabelStatus[4] integerValue]];
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            break;
        case 10006:
            if ([self.allLabelStatus[5] integerValue] == kMomenyary) {
                // 当是模式3的时候，松手变成模式“关”
                [self changeStatusWithArrayIndex:5 Num:[self.allLabelStatus[5] integerValue]];
                // 修改显示的文字
                self.labelStatus1.text = self.statusTexts[[self.allLabelStatus[5] integerValue]];
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            break;
        default:
            break;
    }
}

// 按下时触发
- (IBAction)onOffBtnTouchDown:(UIButton *)btn {
    // 修改灯开关的标志位
    switch (btn.tag) {
        case 10001:
            if (btn.selected) {
                _whickLamp -= 1;
            } else {
                _whickLamp += 1;
            }
            offOnAndStatusbtnSendCode[3] = _whickLamp;
            btn.selected = !btn.selected;
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            break;
        case 10002:
            if (btn.selected) {
                _whickLamp -= 2;
            } else {
                _whickLamp += 2;
            }
            offOnAndStatusbtnSendCode[3] = _whickLamp;
            btn.selected = !btn.selected;
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            break;
        case 10003:
            if (btn.selected) {
                _whickLamp -= 4;
            } else {
                _whickLamp += 4;
            }
            offOnAndStatusbtnSendCode[3] = _whickLamp;
            btn.selected = !btn.selected;
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            break;
        case 10004:
            if (btn.selected) {
                _whickLamp -= 8;
            } else {
                _whickLamp += 8;
            }
            offOnAndStatusbtnSendCode[3] = _whickLamp;
            btn.selected = !btn.selected;
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            break;
        case 10005:
            if (btn.selected) {
                _whickLamp -= 16;
            } else {
                _whickLamp += 16;
            }
            offOnAndStatusbtnSendCode[3] = _whickLamp;
            btn.selected = !btn.selected;
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            break;
        case 10006:
            if (btn.selected) {
                _whickLamp -= 32;
            } else {
                _whickLamp += 32;
            }
            offOnAndStatusbtnSendCode[3] = _whickLamp;
            btn.selected = !btn.selected;
            
            [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            break;
        default:
            break;
    }
}

- (IBAction)statusBtnClick:(UIButton *)btn {
    // 修改模式
    switch (btn.tag) {
        case 20001:
            // 改变模式，修改发送的数据
            [self changeStatusWithArrayIndex:0 Num:[self.allLabelStatus[0] integerValue]];
            // 修改显示的文字
            self.labelStatus1.text = self.statusTexts[[self.allLabelStatus[0] integerValue]];
            // 当开关开着才发送数据
            if (self.btnOnOff1.isSelected) {
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            // 当开关开着，并且按钮是模式3，立刻关闭按钮
            if (self.btnOnOff1.isSelected && [self.allLabelStatus[0] integerValue] == kMomenyary) {
                [self onOffBtnTouchDown:self.btnOnOff1];
            }
            break;
        case 20002:
            
            [self changeStatusWithArrayIndex:1 Num:[self.allLabelStatus[1] integerValue]];
            self.labelStatus2.text = self.statusTexts[[self.allLabelStatus[1] integerValue]];
            if (self.btnOnOff2.isSelected) {
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            if (self.btnOnOff2.isSelected && [self.allLabelStatus[1] integerValue] == kMomenyary) {
                [self onOffBtnTouchDown:self.btnOnOff2];
            }
            break;
        case 20003:
            
            [self changeStatusWithArrayIndex:2 Num:[self.allLabelStatus[2] integerValue]];
            self.labelStatus3.text = self.statusTexts[[self.allLabelStatus[2] integerValue]];
            if (self.btnOnOff3.isSelected) {
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            if (self.btnOnOff3.isSelected && [self.allLabelStatus[2] integerValue] == kMomenyary) {
                [self onOffBtnTouchDown:self.btnOnOff3];
            }
            break;
        case 20004:
            
            
            [self changeStatusWithArrayIndex:3 Num:[self.allLabelStatus[3] integerValue]];
            self.labelStatus4.text = self.statusTexts[[self.allLabelStatus[3] integerValue]];
            if (self.btnOnOff4.isSelected) {
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            if (self.btnOnOff4.isSelected && [self.allLabelStatus[3] integerValue] == kMomenyary) {
                [self onOffBtnTouchDown:self.btnOnOff4];
            }
            break;
        case 20005:
            [self changeStatusWithArrayIndex:4 Num:[self.allLabelStatus[4] integerValue]];
            self.labelStatus5.text = self.statusTexts[[self.allLabelStatus[4] integerValue]];
            if (self.btnOnOff5.isSelected) {
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            if (self.btnOnOff5.isSelected && [self.allLabelStatus[4] integerValue] == kMomenyary ) {
                [self onOffBtnTouchDown:self.btnOnOff5];
            }
            break;
        case 20006:
            [self changeStatusWithArrayIndex:5 Num:[self.allLabelStatus[5] integerValue]];
            self.labelStatus6.text = self.statusTexts[[self.allLabelStatus[5] integerValue]];
            if (self.btnOnOff6.isSelected) {
                [self writePeripheral:self.mPeripheral characteristic:self.FFFAcharacteristic value:[self convertCode:offOnAndStatusbtnSendCode]];
            }
            if (self.btnOnOff6.isSelected && [self.allLabelStatus[5] integerValue] == kMomenyary) {
                [self onOffBtnTouchDown:self.btnOnOff6];
            }
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

- (IBAction)closeVc:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有方法

/**
 *  改变模式，修改发送的数据
 *
 */
- (void)changeStatusWithArrayIndex:(NSInteger)index Num:(NSInteger)num {
    
    num += 1;
    
    // 大于3重置
    if (num > self.statusHex.count - 1) {
        num = 0;
    }
    
    // 保存当前状态
    self.allLabelStatus[index] = @(num);
    // 修改发送数据的值
    offOnAndStatusbtnSendCode[4 + index] = [self.statusHex[num] integerValue];
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
 *  开始马上发送的Code
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
    NSLog(@"%zd", [NSData dataWithBytes:codes length:kDataLength].length);
    NSLog(@"%@", [[NSString alloc] initWithData:[NSData dataWithBytes:codes length:kDataLength]  encoding:NSUTF8StringEncoding]);
    return [NSData dataWithBytes:codes length:kDataLength];
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
                
                
                [self writePeripheral:peripheral characteristic:characteristic value:[self startCode]];
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
            BOOL lockFlag = [self checkLock:backCode];
            if (lockFlag) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"设备已经被锁定" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                [alertView show];
//                return;
            }
            self.lockSwichBtn.on = lockFlag;
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

//写数据
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

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

//停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
    
}



@end