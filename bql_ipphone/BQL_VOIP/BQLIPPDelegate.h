//
//  BQLIPPDelegate.h
//  LinPhone
//
//  Created by hao Mr Lin. on 16/7/13.
//  Copyright © 2016年 hao Mr Lin.. All rights reserved.
//

#ifndef BQLIPPDelegate_h
#define BQLIPPDelegate_h

#import "BQLIPPStatus.h"
@protocol BQLIPPDelegate <NSObject>
@optional


//  登陆状态变化回调
- (void)onRegisterStateChange:(BQLRegistrationState) state message:(const char*) message;

// 发起来电回调
- (void)onOutgoingCall:(BQLCall *)call withState:(BQLCallState)state withMessage:(NSDictionary *) message;

// 收到来电回调
- (void)onIncomingCall:(BQLCall *)call withState:(BQLCallState)state withMessage:(NSDictionary *) message;

// 接听回调
-(void)onAnswer:(BQLCall *)call withState:(BQLCallState)state withMessage:(NSDictionary *) message;

// 释放通话回调
- (void)onHangUp:(BQLCall *)call withState:(BQLCallState)state withMessage:(NSDictionary *) message;

// 呼叫失败回调
- (void)onDialFailed:(BQLCallState)state withMessage:(NSDictionary *) message;


@end

#endif /* BQLIPPDelegate_h */
