//
//  BQLIPPStatus.h
//  LinphoneDemo
//
//  Created by hao Mr Lin on 16/7/13.
//  Copyright © 2016年 haoMr Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BQLIPPStatus : NSObject

typedef enum _BQLRegistrationState{
    BQLRegistrationNone,                       /**<登陆信息初始化*/
    BQLRegistrationProgress,                /**<登陆中 */
    BQLRegistrationOk,                           /**< 登陆成功 */
    BQLRegistrationCleared,                   /**< 注销成功 */
    BQLRegistrationFailed                       /**<登陆失败 */
}BQLRegistrationState;

typedef enum _BQLCallState{
    BQLCallIdle,                                        /**<0通话初始化 */
    BQLCallIncomingReceived,              /**<1收到来电 */
    BQLCallOutgoingInit,                         /**<2呼出电话初始化 */
    BQLCallOutgoingProgress,              /**<3呼出电话拨号中 */
    BQLCallOutgoingRinging,                 /**<4呼出电话正在响铃 */
    BQLCallOutgoingEarlyMedia,           /**<5An outgoing call is proposed early media */
    BQLCallConnected,                           /**<6通话连接成功*/
    BQLCallStreamsRunning,                 /**<7媒体流已建立*/
    BQLCallPausing,                                 /**<8通话暂停中 */
    BQLCallPaused,                                 /**<9通话暂停成功*/
    BQLCallResuming,                             /**<10通话被恢复*/
    BQLCallRefered,                                 /**<11通话转移*/
    BQLCallError,                                      /**<12通话错误*/
    BQLCallEnd,                                        /**<13通话正常结束*/
    BQLCallPausedByRemote,               /**<14通话被对方暂停*/
    BQLCallUpdatedByRemote,              /**<15对方请求更新通话参数 */
    BQLCallIncomingEarlyMedia,             /**<16We are proposing early media to an incoming call */
    BQLCallUpdating,                                 /**<17A call update has been initiated by us */
    BQLCallReleased,                                /**<18通话被释放 */
    BQLCallEarlyUpdatedByRemote,       /*<19通话未应答.*/
    BQLCallEarlyUpdating,                        /*<20通话未应答我方*/
    BQLCallNumberError                           /*<21号码有误*/
} BQLCallState;

extern NSString *const kBQLRegistrationUpdate;

extern NSString *const kBQLCallUpdate;

extern NSString *const kBQLCoreUpdate;

// 登录通知
extern NSString *const kBQLLoginStatus;
// 通话已挂断通知
extern NSString *const kBQLCallReleased;
// 正在拨号通知
extern NSString *const kBQLCalling;
// 接听通话已建立通知
extern NSString *const kBQLCallConnected;

// 通话strut
typedef struct _LinphoneCall BQLCall;
typedef struct _LinphoneCallParams BQLCallParams;

@end
