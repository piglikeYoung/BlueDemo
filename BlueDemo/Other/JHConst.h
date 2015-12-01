//
//  JHConst.h
//  BlueDemo
//
//  Created by piglikeyoung on 15/11/8.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define JHLog(...) NSLog(__VA_ARGS__)
#else
#define JHLog(...)
#endif

#define JHNotificationCenter [NSNotificationCenter defaultCenter]

extern NSString *const JHSelectPresetDidChangeNotification;
extern NSString *const JHSelectPresetObjKey;

extern NSString *const JHSavePresetNotification;
extern NSString *const JHSavePresetObjKey;


extern NSString *const kSavePresetCodeKey;