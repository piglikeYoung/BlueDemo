//
//  ColorBoardViewController.h
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/29.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import <UIKit/UIKit.h>

// 选好色块的回调block
typedef void (^ColorBoardConfirmBlock)(NSInteger colorBoardTag);

@interface ColorBoardViewController : UIViewController

@property (nonatomic, copy) ColorBoardConfirmBlock confirmBlock;

// 旧的选中色块的tag
@property (nonatomic, assign) NSInteger oldColorTag;

@end
