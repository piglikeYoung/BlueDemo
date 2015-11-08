//
//  ConnectionViewController.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/27.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "ConnectionViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SwitchViewController.h"
#import "RGBViewController.h"
#import "Masonry.h"
#import "JHConst.h"

// 蓝牙外设名称
static NSString *const switchDeviceName = @"XIANGXI-CSL-5233";
static NSString *const rgbDeviceName = @"XIANGXI-CSL-5233-2";


@interface ConnectionViewController ()<CBCentralManagerDelegate>

// 系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
@property (nonatomic, strong) CBCentralManager *manager;

// 保存扫描到的蓝牙设备
@property (nonatomic, strong) NSMutableArray *mPeripheralList;

// Switch蓝牙设备
@property (nonatomic, strong) CBPeripheral *switchPeripheral;
// RGB蓝牙设备
@property (nonatomic, strong) CBPeripheral *rgbPeripheral;


@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *rgbBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIImageView *logoIv;
@property (weak, nonatomic) IBOutlet UIImageView *rgbControlIv;
@property (weak, nonatomic) IBOutlet UIImageView *switchControlIv;

@end

@implementation ConnectionViewController

- (NSMutableArray *)mPeripheralList {
    if (!_mPeripheralList) {
        _mPeripheralList = [NSMutableArray array];
    }
    return _mPeripheralList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置启动界面动画
    [self setUpLauchIvWithLaunchScreen];
    
    // 1.创建中心设备
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)dealloc {
    // 断开连接并取消引用
    [self disconnectPeripheral:_manager peripheral:_switchPeripheral];
    [self disconnectPeripheral:_manager peripheral:_rgbPeripheral];
    
    if (self.mPeripheralList.count > 0) {
        [self.mPeripheralList removeAllObjects];
    }
    
    if (self.switchPeripheral) {
        self.switchPeripheral = nil;
        self.switchBtn.selected = NO;
    }
    
    if (self.rgbPeripheral) {
        self.rgbPeripheral = nil;
        self.rgbBtn.selected = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 判断跳到那个控制器
    if ([segue.identifier isEqualToString:@"toSwitchVc"]) {
        SwitchViewController *destVc = segue.destinationViewController;
        destVc.mPeripheral = self.switchPeripheral;
    } else if([segue.identifier isEqualToString:@"toRGBVc"]) {
        RGBViewController *destVc = segue.destinationViewController;
        destVc.mPeripheral = self.rgbPeripheral;
    }
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
 *  设置启动界面动画
 */
- (void) setUpLauchIvWithLaunchScreen {
    
    // 加载LaunchScreen.storyboard
    UIViewController *launchScreenVc = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:@"LaunchScreen"];
    
    UIView *launchView = launchScreenVc.view;
    [self.view addSubview:launchView];
    [launchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
    }];
    
    // 外圈转动动画
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    rotationAnimation.duration = 1.f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 8;
    [[launchView viewWithTag:1220].layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    // 3秒后，移除加载动画并显示主界面
    [UIView animateWithDuration:2.0f delay:3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        launchView.alpha = 0.0f;
        launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.3f, 1.3f, 1.0f);
        _bgView.alpha = 1.0f;
        _logoIv.alpha = 1.0f;
        _rgbBtn.alpha = 1.0f;
        _switchBtn.alpha= 1.0f;
        _rgbControlIv.alpha = 1.0f;
        _switchControlIv.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [launchView removeFromSuperview];
    }];
}



// 停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
    
}


#pragma mark - CBCentralManagerDelegate
/*
 主设备状态改变的委托，在初始化CBCentralManager的适合会打开设备，只有当设备正确打开后才能使用
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            JHLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            JHLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            JHLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            JHLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            JHLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            JHLog(@">>>CBCentralManagerStatePoweredOn");
            //开始扫描周围的外设
            /*
             第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
             - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
             */
            [self.manager scanForPeripheralsWithServices:nil options:nil];
            
            break;
        default:
            break;
    }
    
}

// 扫描到设备会进入方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    JHLog(@"扫描到设备:%@",peripheral);
    JHLog(@"信号强度:%@",RSSI);
    
    // 添加到数组
    if (![self.mPeripheralList containsObject:peripheral]) {
        [self.mPeripheralList addObject:peripheral];
    }
    
    // 判断如果名称相同，就连接设备
    if ([peripheral.name isEqualToString:switchDeviceName]) {
        [self.manager connectPeripheral:peripheral options:nil];
    } else if ([peripheral.name isEqualToString:rgbDeviceName]) {
        [self.manager connectPeripheral:peripheral options:nil];
    }
}


/*
 连接到Peripherals失败
 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    JHLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
    
    if ([peripheral.name isEqualToString:switchDeviceName]) {
        [self.switchBtn setImage:[UIImage imageNamed:@"conn_switchBtn_notConnected"] forState:UIControlStateSelected];
        self.switchBtn.selected = YES;
    } else if ([peripheral.name isEqualToString:rgbDeviceName]) {
        [self.rgbBtn setImage:[UIImage imageNamed:@"conn_rgbBtn_notConnected"] forState:UIControlStateSelected];
        self.rgbBtn.selected = YES;
    }
}

/*
 Peripherals断开连接
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    JHLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    
    if (self.mPeripheralList.count > 0) {
        [self.mPeripheralList removeAllObjects];
    }
    
    if (self.switchPeripheral) {
        self.switchPeripheral = nil;
        self.switchBtn.selected = NO;
    }
    
    if (self.rgbPeripheral) {
        self.rgbPeripheral = nil;
        self.rgbBtn.selected = NO;
    }
    
    // 重新扫描
    if (!self.manager.isScanning) {
        [self.manager scanForPeripheralsWithServices:nil options:nil];
    }
    
}
/*
 连接到Peripherals-成功
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    JHLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    
    // 停止扫描
    [self.manager stopScan];
    
    // 强引用设备，不让它释放
    if ([peripheral.name isEqualToString:switchDeviceName]) {
        self.switchPeripheral = peripheral;
        [self.switchBtn setImage:[UIImage imageNamed:@"conn_switchBtn_connected"] forState:UIControlStateSelected];
        self.switchBtn.selected = YES;
    } else if ([peripheral.name isEqualToString:rgbDeviceName]) {
        self.rgbPeripheral = peripheral;
        [self.rgbBtn setImage:[UIImage imageNamed:@"conn_rgbBtn_connected"] forState:UIControlStateSelected];
        self.rgbBtn.selected = YES;
    }

}


@end
