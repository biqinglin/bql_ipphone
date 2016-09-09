//
//  UCSIPCCSDKLog.h
//  LinphoneDemo
//
//  Created by hao Mr Lin on 16/7/14.
//  Copyright © 2016年 hao Mr Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  本类是提供格式化输出日志
 */

@interface BQLIPPSDKLog : NSObject

+ (void) saveDemoLogInfo:(NSString *) summary withDetail:(NSString *) detail;

@end
