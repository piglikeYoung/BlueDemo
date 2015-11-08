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

@interface JHSelectPresetView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *selectPresetDic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JHSelectPresetView

+ (instancetype)showView
{
    
    return [[[NSBundle mainBundle] loadNibNamed:@"JHSelectPresetView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    self.selectPresetDic = [[NSUserDefaults standardUserDefaults] objectForKey:kSavePresetCodeKey];
}

- (IBAction)cancel:(UIButton *)sender {
    
    // 发出通知
    [JHNotificationCenter postNotificationName:JHSelectPresetDidChangeNotification object:nil userInfo:nil];
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selectPresetDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"JHSelectPresetViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = [_selectPresetDic allKeys][indexPath.row];
    
    return cell;
}

#pragma mark - 代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [_selectPresetDic allKeys][indexPath.row];
    // 发出通知
    [JHNotificationCenter postNotificationName:JHSelectPresetDidChangeNotification object:nil userInfo:@{JHSelectPresetObjKey : key}];
}


@end
