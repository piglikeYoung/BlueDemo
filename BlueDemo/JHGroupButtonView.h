//
//  JHGroupButtonView.h
//  BlueDemo
//
//  Created by piglikeyoung on 15/12/5.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MultipleSelectedClickBlock)(NSMutableArray *integerArray);
typedef void(^MultipleCanelClickBlock)();

@interface JHGroupButtonView : UIView

+ (instancetype)showView;

@property (nonatomic, copy) NSMutableArray *recoveryCode;

@property (nonatomic, copy) MultipleSelectedClickBlock multipleSelectedClickBlock;
@property (nonatomic, copy) MultipleCanelClickBlock multipleCanelClickBlock;

@end
