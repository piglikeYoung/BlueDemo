//
//  UIColor+Convert.h
//  ColorPickDemo
//
//  Created by piglikeyoung on 15/10/26.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Convert)

/**
 *  将十六进制的字符串转为颜色
 *
 *  @param color 十六进制数
 *  @param alpha 透明度
 *
 *  @return 颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
