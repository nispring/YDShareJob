//
//  AppDelegate.m
//  YDShareJob
//
//  Created by 李加建 on 2017/10/17.
//  Copyright © 2017年 jack. All rights reserved.
//

#import "AppDelegate.h"


#import <AVOSCloud/AVOSCloud.h>

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

#import <UMMobClick/MobClick.h>
#import <UMMobClick/MobClickSocialAnalytics.h>
#import <UMMobClick/MobClickGameAnalytics.h>



#import "JobDefaultViewController.h"

#import "ViewController.h"

#import "TabBarViewController.h"




@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    self.window = [[UIWindow alloc]initWithFrame:SCREEM ];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    
    [self setupWithOptions:launchOptions];
    
//    Home1_2ViewController *tabBar = [[Home1_2ViewController alloc]init];
//    
//    self.window.rootViewController = [[UIBaseNavigationController alloc]initWithRootViewController:tabBar];
    
    self.window.rootViewController = [[TabBarViewController alloc]init];
    
    //    UINavigationBar *navBar = [UINavigationBar appearance];
    //    navBar.barTintColor = RGB(50, 50, 50);
    //    navBar.translucent = NO;
    //
    //    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //
    //    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    NSString *open = NSLocalizedStringFromTable(@"isopen",@"InfoPlist", nil);
    
    BOOL isopen = [open boolValue];
    
    if(isopen == YES){
        
        [self loadJobDefault];
    }
    
    application.applicationIconBadgeNumber = 0;

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}





- (void)loadJobDefault {
    
    [AVAnalytics updateOnlineConfigWithBlock:^(NSDictionary *dict, NSError *error) {
        if (error == nil) {
            // 从 dict 中读取参数，dict["k1"] 值应该为 v1
            
            NSDictionary * parameters = dict[@"parameters"];
            
            NSString *bid2 = BUNDLEID;
            
            NSInteger tag = [parameters[bid2] integerValue];
            
            if(tag == 1){
                
                JobDefaultViewController *root = [[JobDefaultViewController alloc]init];
                
                UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:root];
                
                self.window.rootViewController = navi;
                
                [UserManager saveBannver:BUNDLEID];
            }
            else {
                
                [UserManager removeBanner];
            }
            
        }
    }];
    
}





- (void)setupWithOptions:(NSDictionary *)launchOptions  {
    
    [self cloudWithOptions:launchOptions];
    [self jpushWithOptions:launchOptions];
    [self umengWithOptions:launchOptions];
    
    
}



#pragma mark - AVOSCloud

- (void)cloudWithOptions:(NSDictionary *)launchOptions  {
    
#pragma mark appkey
    NSString * appid = CloudID;
    NSString * appkey = CloudKey;
    
    [AVOSCloud setApplicationId:appid clientKey:appkey];
    
    // 放在 SDK 初始化语句 [AVOSCloud setApplicationId:] 后面，只需要调用一次即可
    [AVOSCloud setAllLogsEnabled:YES];
    
    // 如果想跟踪统计应用的打开情况，后面还可以添加下列代码：
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    
    
}


#pragma mark - JPush
- (void)jpushWithOptions:(NSDictionary *)launchOptions {
    
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    
#pragma mark appkey
    NSString *appkey = JPushKey;
    
    NSString *channel = @"channel";
    BOOL  isProduction = YES;
    
    advertisingId = @"";
    
    [JPUSHService setupWithOption:launchOptions appKey:appkey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
        
    }];
    
    
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
    
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"willPresentN" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //
    //    [alert show];
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
    
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"didReceiv" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //
    //    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}


#pragma mark - UMeng
- (void)umengWithOptions:(NSDictionary *)launchOptions {
    
    
    UMAnalyticsConfig * config = [UMAnalyticsConfig sharedInstance];
#pragma mark appkey
    config.appKey = UMengKey;
    config.channelId = @"App Store";
    //    config.eSType = E_UM_GAME; //仅适用于游戏场景，应用统计不用设置
    
    [MobClick startWithConfigure:UMConfigInstance];
}



@end
