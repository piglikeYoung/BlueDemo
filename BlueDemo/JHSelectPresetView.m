//
//  JHSelectPresetView.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/11/8.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "JHSelectPresetView.h"
#import "UIView+Extension.h"
#import "JHConst.h"

@interface JHSelectPresetView()

@property (nonatomic, strong) NSDictionary *selectPresetDic;
@property (nonatomic, strong) NSArray *keyNameList;
@property (nonatomic, assign) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UILabel *currentSelect;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation JHSelectPresetView

+ (instancetype)showView
{
    
    return [[[NSBundle mainBundle] loadNibNamed:@"JHSelectPresetView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    self.selectPresetDic = [[NSUserDefaults standardUserDefaults] objectForKey:kSavePresetCodeKey];
    self.keyNameList = [self.selectPresetDic allKeys];
    // 默认第一个
    self.currentIndex = 0;
    self.currentSelect.text = self.keyNameList[self.currentIndex];
    
    if (self.keyNameList.count <= 0) {
        self.leftBtn.enabled = NO;
        self.rightBtn.enabled = NO;
        self.saveBtn.enabled = NO;
    }
}

- (IBAction)cancel:(UIButton *)sender {
    
    // 发出通知
    [JHNotificationCenter postNotificationName:JHSelectPresetDidChangeNotification object:nil userInfo:nil];
}

- (IBAction)save:(UIButton *)sender {
    NSString *key = self.currentSelect.text;
    // 发出通知
    [JHNotificationCenter postNotificationName:JHSelectPresetDidChangeNotification object:nil userInfo:@{JHSelectPresetObjKey : key}];
}

- (IBAction)leftBtnClick:(id)sender {
    if (self.currentIndex == 0) {
        return;
    } else {
        self.currentIndex--;
        self.currentSelect.text = self.keyNameList[self.currentIndex];
    }
    
}

- (IBAction)rightBtnClick:(id)sender {
    if (self.currentIndex == self.keyNameList.count - 1) {
        return;
    } else {
        self.currentIndex++;
        self.currentSelect.text = self.keyNameList[self.currentIndex];
    }
}

@end
