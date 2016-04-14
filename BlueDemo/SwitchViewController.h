//
//  SwitchViewController.h
//  BleDemo
//
//  Created by piglikeyoung on 15/10/11.
//  Copyright © 2015年 liuyanwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SwitchViewController : UIViewController

// Switch蓝牙设备
@property (nonatomic, strong) CBPeripheral *mPeripheral;

@end
