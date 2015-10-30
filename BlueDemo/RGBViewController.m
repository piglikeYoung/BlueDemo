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
@property (weak, nonatomic) IBOutlet UIStackView *modelStackView;

@property (weak, nonatomic) IBOutlet UIButton *carBtn1;
@property (weak, nonatomic) IBOutlet UIButton *carBtn2;
@property (weak, nonatomic) IBOutlet UIButton *carBtn3;
@property (weak, nonatomic) IBOutlet UIButton *carBtn4;
@property (weak, nonatomic) IBOutlet UIButton *carBtn5;
@property (weak, nonatomic) IBOutlet UIButton *carBtn6;

@property (weak, nonatomic) IBOutlet UISwitch *masterSwitch;

@property (weak, nonatomic) UISlider *leftSlider;
@property (weak, nonatomic) UISlider *rightSlider;

// 特征对象
@property (nonatomic, strong) CBCharacteristic *FFFAcharacteristic;
@property (nonatomic, strong) CBCharacteristic *FFFBcharacteristic;

// 蓝牙传输数据
@property (nonatomic, strong) NSMutableArray *transferCode;

// 6个车按钮对应的value
@property (nonatomic, strong) NSArray *carBtnValueArray;

// 保存选中的按钮数组
@property (nonatomic, strong) NSMutableArray *carSelectedBtnArray;

@end

@implementation RGBViewController

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
    
    [self setUpSlider];
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
 *  设置左右Slider控件
 */
- (void)setUpSlider {
    UISlider *leftSlider = [[UISlider alloc] init];
    [self.view addSubview:leftSlider];
    [leftSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [leftSlider setMinimumTrackImage:[UIImage resizedImage:@"slider"] forState:UIControlStateNormal];
    [leftSlider setMaximumTrackImage:[UIImage resizedImage:@"slider"] forState:UIControlStateNormal];
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
    self.rightSlider = rightSlider;
    rightSlider.transform =  CGAffineTransformMakeRotation( -M_PI * 0.5 );
    [rightSlider addTarget:self action:@selector(brightnessOrSpeedSlider:) forControlEvents:UIControlEventValueChanged];
    [rightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(kSliderWidth * 0.5  - 25);
        make.centerY.equalTo(self.view.mas_centerY).offset(-20);
        make.width.mas_equalTo(kSliderWidth);
    }];
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
    
    
    
    if (self.masterSwitch.isOn) {
        [self writePeripheral:_mPeripheral characteristic:_FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.transferCode]];
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
            
//            sender.selected = !sender.selected;
//            
//            if (sender.isSelected) {
//                // 第2个字节(数组的第三位)，每选中一个按钮在原来的基础加上对应的value
//                self.transferCode[2] = @([self.transferCode[2] integerValue] + [self.carBtnValueArray[0] integerValue]);
//                
//                
//            } else {
//                // 第2个字节(数据的第三位)，每选中一个按钮在原来的基础减去对应的value
//                self.transferCode[2] = @([self.transferCode[2] integerValue] - [self.carBtnValueArray[0] integerValue]);
//            }
//            
//            // 第3个字节(数组的第四位)，赋值操作的按钮对应的value
//            self.transferCode[3] = self.carBtnValueArray[0];
//            
//            
//            
//            if (self.masterSwitch.isOn) {
//                [self writePeripheral:_mPeripheral characteristic:_FFFAcharacteristic value:[self converToCharArrayWithIntegerArray:self.transferCode]];
//            }
            
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

- (void) brightnessOrSpeedSlider:(UISlider *)slider {
    NSLog(@"%f", slider.value);
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
