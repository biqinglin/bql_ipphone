//
//  AppDelegate.m
//  bql_ipphone
//
//  Created by hao 好享购 on 16/7/15.
//  Copyright © 2016年 hao 好享购. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginVC.h"
#import "ContacterListVC.h"
#import "CallingVC.h"
#import "AnswerVC.h"
#import "BQLIPPManager.h"

@interface AppDelegate () <BQLIPPDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[BQLIPPManager InstanceIPPManager] setDelegate:self];
    [[BQLIPPManager InstanceIPPManager] startBQLIPP];
    
    if(isfirstStart()) {
        
        LoginVC *login=[[LoginVC alloc]init];
        UINavigationController *nav= [[UINavigationController alloc]initWithRootViewController:login];
        self.window.rootViewController = nav;
    }
    else {
        
        ContacterListVC *list=[[ContacterListVC alloc]init];
        UINavigationController *nav= [[UINavigationController alloc]initWithRootViewController:list];
        self.window.rootViewController = nav;
    }
    return YES;
}

//  登陆状态变化回调
- (void)onRegisterStateChange:(BQLRegistrationState)state message:(const char*)message {
    
    NSLog(@"登陆状态变化回调%u-%s",state,message);
    [[NSNotificationCenter defaultCenter] postNotificationName:kBQLLoginStatus object:nil userInfo:@{@"status":@(state)}];
}

// 发起来电回调
- (void)onOutgoingCall:(BQLCall *)call withState:(BQLCallState)state withMessage:(NSDictionary *)message {
    
    NSLog(@"发起来电回调%u-%@",state,message);
    [[NSNotificationCenter defaultCenter] postNotificationName:kBQLCalling object:nil userInfo:nil];
}

// 收到来电回调
- (void)onIncomingCall:(BQLCall *)call withState:(BQLCallState)state withMessage:(NSDictionary *)message {
    
    NSLog(@"收到来电回调%u-%@",state,message);
    // 如果正在通话还有电话打进来不要进行弹窗
    if([[BQLIPPManager InstanceIPPManager] isCalling]) {
        return;
    }
    AnswerVC *answer = [[AnswerVC alloc] init];
    answer.incomeCall = call;
    answer.phoneNumber = [[BQLIPPManager InstanceIPPManager] getCorrectPhoneNumber:message[@"remote_address"]];
    answer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self topViewController] presentViewController:answer animated:YES completion:nil];
}

// 接听回调
-(void)onAnswer:(BQLCall *)call withState:(BQLCallState)state withMessage:(NSDictionary *)message {
    
    NSLog(@"接听回调%u-%@",state,message);
    [[NSNotificationCenter defaultCenter] postNotificationName:kBQLCallConnected object:nil userInfo:nil];
}

// 释放通话回调
- (void)onHangUp:(BQLCall *)call withState:(BQLCallState)state withMessage:(NSDictionary *)message {
    
    NSLog(@"释放通话回调%u-%@",state,message);
    [[NSNotificationCenter defaultCenter] postNotificationName:kBQLCallReleased object:nil userInfo:nil];
}

// 呼叫失败回调
- (void)onDialFailed:(BQLCallState)state withMessage:(NSDictionary *) message {
    
    NSLog(@"呼叫失败回调%u-%@",state,message);
}

- (UIViewController*)topViewController {
    
    return [self topViewControllerWithRootViewController:self.window.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    }
    else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    }
    else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    else {
        return rootViewController;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
