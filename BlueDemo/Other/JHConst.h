//
//  JHConst.h
//  BlueDemo
//
//  Created by piglikeyoung on 15/11/8.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG // 调试状态, 打开LOG功能
#define JHLog(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else // 发布状态, 关闭LOG功能
#define JHLog(...)
#endif


#define JHNotificationCenter [NSNotificationCenter defaultCenter]

/*****版本号***/
#define kVersion_App [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define kVersionBuild_App [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]

extern NSString *const JHSelectPresetDidChangeNotification;
extern NSString *const JHSelectPresetObjKey;

extern NSString *const JHSavePresetNotification;
extern NSString *const JHSavePresetObjKey;


extern NSString *const kSavePresetCodeKey;