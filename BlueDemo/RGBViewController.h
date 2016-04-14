//
//  RGBViewController.h
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/27.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface RGBViewController : UIViewController

// 主界面蓝牙设备
@property (nonatomic, strong) CBPeripheral *mPeripheral;

@end
