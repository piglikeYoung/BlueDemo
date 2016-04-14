//
//  JHSavePresetView.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/12/1.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "JHSavePresetView.h"
#import "JHConst.h"

@interface JHSavePresetView()

@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation JHSavePresetView


+ (instancetype)showView
{
    
    return [[[NSBundle mainBundle] loadNibNamed:@"JHSavePresetView" owner:nil options:nil] firstObject];
}


- (void)awakeFromNib {
    
    [_textField becomeFirstResponder];
}

- (IBAction)cancel:(UIButton *)sender {
    
    // 发出通知
    [JHNotificationCenter postNotificationName:JHSavePresetNotification object:nil userInfo:nil];
}

- (IBAction)save:(UIButton *)sender {

    // 获取savePreset名称
    if (_textField.text.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Input text can not be empty" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alertView show];
    } else {
        NSMutableDictionary *savePresetDic = [[self recoveryBlueDeviceStatusWithKeyName:kSavePresetCodeKey] mutableCopy];
        
        // 不存在，创建新的
        if (!savePresetDic) {
            savePresetDic = [NSMutableDictionary dictionary];
        }
        
        if (savePresetDic.count > 10) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Max number of presets is 10" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alertView show];
        } else {
            // 发出通知
            [JHNotificationCenter postNotificationName:JHSavePresetNotification object:nil userInfo:@{JHSavePresetObjKey:_textField.text}];
        }
    }
}

/**
 *  从偏好设置中恢复蓝牙设备的状态，即每个按钮按下的状态
 *
 */
- (instancetype) recoveryBlueDeviceStatusWithKeyName:(NSString *)keyName {
    // 1.获取NSUserDefaults对象
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    return [defaults objectForKey:keyName];
}



@end
