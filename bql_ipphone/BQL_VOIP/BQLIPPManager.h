//
//  BQLIPPManager.h
//  LinphoneDemo
//
//  Created by hao Mr Lin on 16/7/13.
//  Copyright © 2016年 hao Mr Lin. All rights reserved.
//

/**
 *  bql ip phone manager
 */

#import <Foundation/Foundation.h>
#import "BQLIPPStatus.h"
#import "BQLIPPDelegate.h"
#import <UIKit/UIKit.h>

@interface BQLIPPManager : NSObject <BQLIPPDelegate>

/**
 *  回调代理
 */
@property (nonatomic, readwrite, assign) id<BQLIPPDelegate> delegate;

/**
 *  当前通话
 */
@property (nonatomic, assign, readonly) BQLCall *currentCall;

/**
 *  扬声器是否可用
 */
@property (nonatomic, assign) BOOL isSpeakerEnabled;

/**
 *  BQL是否已初始化
 */
@property (nonatomic, assign, readonly) BOOL isBQLReady;

/**
 *  实例化BQLIPPManager
 */
+ (instancetype)InstanceIPPManager;

/**
 *  启动bql ip phone
 */
- (void)startBQLIPP;

/**
 *  用户登录服务端
 *
 *  @param username  用户名
 *  @param password  密码
 *  @param displayName  昵称 (可选项)
 *  @param domain    ip地址
 *  @param port    端口号 (可选项)
 *  @param transport 连接方式 (@"UDP", @"TCP", @"TLS"])
 *
 *  @return 是否登录成功
 */
- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password DisplayName:(NSString *)displayName domain:(NSString*)domain Port:(NSString *)port withTransport:(NSString*)transport;

/**
 *  手机是否处于3G
 *
 *  @return YES Or NO
 */
+ (BOOL)isNotIphone3G;

/**
 *  是否正在通话
 *
 *  @return YES Or NO
 */
- (BOOL)isCalling;

/**
 *  注销登录用户
 */
- (void)logout;

/**
 *  拨打电话
 *
 *  @param address     对方手机号（测试阶段就是后台创建的用户名如100、101，这个映射关系是后台处理的）
 *  @param displayName 对方昵称（可为空）
 *  @param transfer    是否转接（一般为NO）
 */
- (void)call:(NSString *)address displayName:(NSString*)displayName transfer:(BOOL)transfer;

/**
 *  接听通话
 *
 *  @param call call
 */
- (void)answer:(BQLCall *)call;

/**
 *   挂断通话
 */
- (void)hanUpCall;

/**
 *  获取通话时长
 *
 *  @return 时长int
 */
- (int)getCallDuration;

/**
 *   获取对方号码
 *
 *  @return 对方号码
 */
- (NSString *)getRemoteAddress;

/**
 *  获取对方昵称
 *
 *  @return 对方昵称
 */
- (NSString *)getRemoteDisplayName;

/**
 *   获取通话参数
 *
 *  @return 通话参数
 */
- (BQLCallParams *)getCallParams;

/**
 *   将int转为标准格式的NSString时间
 *
 *  @param duration 获取到的时长int类型
 *
 *  @return NSString时间
 */
+ (NSString *)durationToString:(int)duration;

// 目前测试阶段后台是我自己搭建的，拨号接听回调中显示的是sip:手机号@ip地址 形式 此方法提取手机号
- (NSString *)getCorrectPhoneNumber:(NSString *)info;

BOOL isfirstStart();

@end






