//
//  BQLIPPManager.m
//  LinphoneDemo
//
//  Created by hao Mr Lin on 16/7/13.
//  Copyright © 2016年 hao Mr Lin. All rights reserved.
//

#import "BQLIPPManager.h"
#import "LinphoneManager.h"
#import "BQLIPPSDKLog.h"

#define LC ([LinphoneManager getLc])

@implementation BQLIPPManager

/**
 *  实例化BQLIPPManager
 */
+ (instancetype)InstanceIPPManager {
    
    static dispatch_once_t onceToken;
    static BQLIPPManager *ipPManager;
    
    dispatch_once(&onceToken, ^{
        ipPManager = [[BQLIPPManager alloc] init];
    });
    
    return ipPManager;
}

/**
 *  扬声器是否可用
 */
- (BOOL)isSpeakerEnabled {
    
    return [LinphoneManager instance].speakerEnabled;
}

- (void)setIsSpeakerEnabled:(BOOL)isSpeakerEnabled {
    
    [BQLIPPSDKLog saveDemoLogInfo:[NSString stringWithFormat:@"设置扬声器为%d", isSpeakerEnabled] withDetail:nil];
    [[LinphoneManager instance] setSpeakerEnabled:isSpeakerEnabled];
}

/**
 *  获取当前通话
 */
- (BQLCall *)currentCall {
    
    return linphone_core_get_current_call(LC) ? linphone_core_get_current_call(LC) : nil;
}

- (BOOL)isBQLReady {
    
    return [LinphoneManager isLcReady];
}

/**
 *  启动bql ip phone
 */
- (void)startBQLIPP {
    
    [[LinphoneManager instance] startLibLinphone];
    [BQLIPPSDKLog saveDemoLogInfo:@"初始化成功" withDetail:nil];
}

/**
 *  用户登录服务端
 *
 *  @param username  用户名
 *  @param password  密码
 *  @param displayName  昵称
 *  @param domain    ip地址
 *  @param port    端口号
 *  @param transport 端口
 *
 *  @return 是否登录成功
 */
- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password DisplayName:(NSString *)displayName domain:(NSString*)domain Port:(NSString *)port withTransport:(NSString*)transport {
    
    LinphoneCore* lc = [LinphoneManager getLc];
    if (lc == nil) {
        
        [self startBQLIPP];
        lc = [LinphoneManager getLc];
    }
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    NSString* server_address = domain;
    
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(proxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
    
    const char *identity = [[NSString stringWithFormat:@"sip:%@@%@", username, domain] cStringUsingEncoding:NSUTF8StringEncoding];
    
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    if (displayName && displayName.length != 0) {
        linphone_address_set_display_name(linphoneAddress, (displayName.length ? displayName.UTF8String : NULL));
    }
    if( domain && [domain length] != 0) {
        // if(!port) port = @"5060";
        if( transport != nil ){
            server_address = [NSString stringWithFormat:@"%@:%@;transport=%@", server_address, port, [transport lowercaseString]];
        }
        // when the domain is specified (for external login), take it as the server address
        linphone_proxy_config_set_server_addr(proxyCfg, [server_address UTF8String]);
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    }
    
    // 添加了昵称后的identity
    identity = linphone_address_as_string(linphoneAddress);
    //    char* extractedAddres = linphone_address_as_string_uri_only(linphoneAddress);
    linphone_address_destroy(linphoneAddress);
    //    LinphoneAddress* parsedAddress = linphone_address_new(extractedAddres);
    //    ms_free(extractedAddres); // 释放
    
    //    if( parsedAddress == NULL || !linphone_address_is_sip(parsedAddress) ){
    //        if( parsedAddress ) linphone_address_destroy(parsedAddress);
    //        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Check error(s)",nil)
    //                                                            message:NSLocalizedString(@"Please enter a valid username", nil)
    //                                                           delegate:nil
    //                                                  cancelButtonTitle:NSLocalizedString(@"Continue",nil)
    //                                                  otherButtonTitles:nil,nil];
    //        [errorView show];
    //        return FALSE;
    //    }
    //
    //    char *c_parsedAddress = linphone_address_as_string_uri_only(parsedAddress);
    ////    linphone_proxy_config_set_identity(proxyCfg, c_parsedAddress);
    //    linphone_address_destroy(parsedAddress);
    LinphoneAuthInfo* info = linphone_auth_info_new([username UTF8String]
                                                    , NULL, [password UTF8String]
                                                    , NULL
                                                    , linphone_proxy_config_get_realm(proxyCfg)
                                                    ,linphone_proxy_config_get_domain(proxyCfg));
    
    [self setDefaultSettings:proxyCfg];
    
    [self clearProxyConfig];
    
    //    linphone_core_clear_all_auth_info(lc);
    linphone_proxy_config_set_identity(proxyCfg, identity);
    linphone_proxy_config_set_expires(proxyCfg, 2000);
    linphone_proxy_config_enable_register(proxyCfg, true);
    linphone_core_add_auth_info(lc, info);
    linphone_core_add_proxy_config(lc, proxyCfg);
    linphone_core_set_default_proxy_config(lc, proxyCfg);
    ms_free(identity);
    [BQLIPPSDKLog saveDemoLogInfo:@"登陆信息配置成功" withDetail:[NSString stringWithFormat:@"username:%@,\npassword:%@,\ndisplayName:%@\ndomain:%@,\nport:%@\ntransport:%@", username, password, displayName, domain, port, transport]];
    
    // 配置最大接入通话数(多人的话就在这里设置)
    linphone_core_set_max_calls(LC, 1);
    
    [[NSUserDefaults standardUserDefaults] setValue:@"bqlipp" forKey:@"bqlipp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return TRUE;
}

- (void)clearProxyConfig {
    
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
}

- (void)setDefaultSettings:(LinphoneProxyConfig*)proxyCfg {
    
    LinphoneManager* lm = [LinphoneManager instance];
    [lm configurePushTokenForProxyConfig:proxyCfg];
}

/**
 *  手机是否处于3G
 *
 *  @return YES Or NO
 */
+ (BOOL)isNotIphone3G {
    
    return [LinphoneManager isNotIphone3G];
}

/**
 *  是否正在通话
 *
 *  @return YES Or NO
 */
- (BOOL)isCalling {
    
    return linphone_core_in_call(LC);
}

/**
 *  注销登录用户
 */
- (void)logout {
    
    [BQLIPPSDKLog saveDemoLogInfo:@"注销登陆信息" withDetail:nil];
    [[LinphoneManager instance] destroyLibLinphone];
    /*
    if (self.isBQLReady == YES) {
        
        [self clearProxyConfig];
        // [[LinphoneManager instance] destroyLibLinphone];
        [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"pushnotification_preference"];
        
        LinphoneCore *lc = [LinphoneManager getLc];
        LCSipTransports transportValue={5060,5060,-1,-1};
        
        if (linphone_core_set_sip_transports(lc, &transportValue)) {
            [LinphoneLogger logc:LinphoneLoggerError format:"cannot set transport"];
        }
        
        [[LinphoneManager instance] lpConfigSetString:@"" forKey:@"sharing_server_preference"];
        [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"ice_preference"];
        [[LinphoneManager instance] lpConfigSetString:@"" forKey:@"stun_preference"];
        linphone_core_set_stun_server(lc, NULL);
        linphone_core_set_firewall_policy(lc, LinphonePolicyNoFirewall);
    }
    */
}

/**
 *  拨打电话
 *
 *  @param address     对方手机号（测试阶段就是后台创建的用户名如100、101，这个映射关系是后台处理的）
 *  @param displayName 对方昵称（可为空）
 *  @param transfer    是否转接（一般为NO）
 */
- (void)call:(NSString *)address displayName:(NSString*)displayName transfer:(BOOL)transfer {
    
    // 号码有效性判断
    if (![self checkPhoneNumInput:address]) {
        
        [BQLIPPSDKLog saveDemoLogInfo:@"请输入正确的号码" withDetail:[NSString stringWithFormat:@"address:%@,\ndisplayName:%@", address, displayName]];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"号码错误，请输入正确的号码" forKey:@"message"];
        [self.delegate onDialFailed:BQLCallNumberError withMessage:dic];
        return;
    }
    
    [[LinphoneManager instance] call:address displayName:displayName transfer:transfer];
    [BQLIPPSDKLog saveDemoLogInfo:@"拨打电话操作" withDetail:[NSString stringWithFormat:@"address:%@,\ndisplayName:%@", address, displayName]];
}

/**
 *  接听通话
 *
 *  @param call call
 */
- (void)answer:(BQLCall *)call {
    
    [[LinphoneManager instance] acceptCall:call];
    [BQLIPPSDKLog saveDemoLogInfo:@"接听电话操作" withDetail:nil];
}

/**
 *   挂断通话
 */
- (void)hanUpCall {
    
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneCall* currentcall = linphone_core_get_current_call(lc);
    if (linphone_core_is_in_conference(lc) || // In conference
        (linphone_core_get_conference_size(lc) > 0) // Only one conf
        ) {
        
        linphone_core_terminate_conference(lc);
    }
    else if(currentcall != NULL) { // In a call
        
        linphone_core_terminate_call(lc, currentcall);
    }
    else {
//        const MSList* calls = linphone_core_get_calls(lc);
//        if (ms_list_size(calls) == 1) { // Only one call
//            linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
//        }
        const bctbx_list_t *calls = linphone_core_get_calls(lc);
        if(bctbx_list_size(calls) == 1) { // Only one call
            
            linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
        }
    }
}

/**
 *  获取通话时长
 *
 *  @return 时长int
 */
- (int)getCallDuration {
    
    if (LC == nil || self.isBQLReady == NO) {
        return 0;
    }
    int duration = linphone_core_get_current_call(LC) ? linphone_call_get_duration(linphone_core_get_current_call(LC)) : 0;
    return duration;
}

/**
 *   获取对方号码
 *
 *  @return 对方号码
 */
- (NSString *)getRemoteAddress {
    
    if (self.currentCall == nil) {
        return nil;
    }
    LinphoneAddress *address = (LinphoneAddress *)linphone_call_get_remote_address(self.currentCall);
    
    char *uri = linphone_address_as_string_uri_only(address);
    NSString *addressStr = [NSString stringWithUTF8String:uri];
    NSString *normalizedSipAddress = [[addressStr
                                       componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@" "];
    LinphoneAddress *addr = linphone_core_interpret_url(LC, [addressStr UTF8String]);
    
    if (addr != NULL) {
        linphone_address_clean(addr);
        char *tmp = linphone_address_as_string(addr);
        normalizedSipAddress = [NSString stringWithUTF8String:tmp];
        ms_free(tmp);
        linphone_address_destroy(addr);
    }

    return addressStr;
}

/**
 *  获取对方昵称
 *
 *  @return 对方昵称
 */
- (NSString *)getRemoteDisplayName {
    
    if (self.currentCall == nil) {
        return nil;
    }
    LinphoneAddress *address = (LinphoneAddress *)linphone_core_get_current_call_remote_address(LC);

    char *uri = (char *)linphone_address_get_display_name(address);
    if (uri) {
        
        return [NSString stringWithUTF8String:uri];
    }
    return @"";
}

/**
 *   获取通话参数
 *
 *  @return 通话参数
 */
- (BQLCallParams *)getCallParams {
    
    if(!self.currentCall) {
        return nil;
    }
    return (BQLCallParams *)linphone_call_get_current_params(self.currentCall);
}

/**
 *   将int转为标准格式的NSString时间
 *
 *  @param duration 获取到的时长int类型
 *
 *  @return NSString时间
 */
+ (NSString *)durationToString:(int)duration {
    
    NSMutableString *result = [[NSMutableString alloc] init];
    if (duration / 3600 > 0) {
        
        [result appendString:[NSString stringWithFormat:@"%02i:", duration / 3600]];
        duration = duration % 3600;
    }
    return [result stringByAppendingString:[NSString stringWithFormat:@"%02i:%02i", (duration / 60), (duration % 60)]];
}

/**
 *  验手机号的合法性
 *
 *  @param mobileNum 手机号
 *
 *  @return 是否合法
 */
- (BOOL)checkPhoneNumInput:(NSString *)mobileNum
{
    if (mobileNum.length == 14)
    {
        return YES;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
     * 电信号段: 133,153,180,181,189,177,1700
     */
    NSString *MOBILE = @"^1((3[0-9]|4[57]|5[0-35-9]|7[0678]|8[0-9])\\d{8}$)";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     */
    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186,145,176,1709
     */
    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
    /**
     * 中国电信：China Telecom
     * 133,153,180,181,189,177,1700
     */
    NSString *CT = @"(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
    /**
         * 大陆地区固话及小灵通
         * 区号：010,020,021,022,023,024,025,027,028,029
         * 号码：七位或八位
         */
    NSString *PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestphs evaluateWithObject:mobileNum] == YES)) {
        
        return YES;
    }
    else {
        
        return NO;
    }
}

- (NSString *)getCorrectPhoneNumber:(NSString *)info {
    
    if(info.length < 15) return info;
    else {
        
        return [info substringWithRange:NSMakeRange(4, 11)];
    }
}

/**
 *  是否为第一次启动
 *
 *  @return yes or no
 */
BOOL isfirstStart() {
    
    id result = [[NSUserDefaults standardUserDefaults] objectForKey:@"bqlipp"];
    if(result && [result isEqualToString:@"bqlipp"]) {
        
        return NO;
    }
    else {

        return YES;
    }
}

@end










