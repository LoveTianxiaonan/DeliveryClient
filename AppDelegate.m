//
//  AppDelegate.m
//  DeliveryClient
//
//  Created by yao on 2018/5/9.
//  Copyright © 2018年 yao. All rights reserved.
//

#import "AppDelegate.h"
#import <MaxLeap/MLTestUtils.h>

/*
 使用cocoapods管理的高德地图库，别的库都是直接放在本地的
 */
@interface AppDelegate ()

@property (nonatomic, strong) CLLocationManager *lcManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:@"LogoutNotification" object:nil];
    if ([CLLocationManager authorizationStatus] < kCLAuthorizationStatusAuthorizedAlways) {
        self.lcManager = [CLLocationManager new];
        [self.lcManager requestWhenInUseAuthorization];
    }
    [self configureLeapCloud];
    [self registerNotifications];
    
    [AMapServices sharedServices].apiKey = (NSString *)APIKey;
    
    [[UINavigationBar appearance] setBackgroundColor:[UIColor blueColor]];
    
    if (kSharedDeliveryPerson.userSession.length > 0) {
        SYTabBarViewController *tabbarVC = [SYTabBarViewController initTabbarVCFromNibFile];
        self.window.rootViewController = tabbarVC;
    }else {
        SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = loginVC;
    }
    
    return YES;
}

- (void)logOut {
    
}

- (void)configureLeapCloud {
#if defined(kProductEnvironment)
    [[MLTestUtils sharedInstance] setEnvironment:MLEnvironmentProd];
#elif defined(kUATEnvironment)
    [[MLTestUtils sharedInstance] setEnvironment:MLEnvironmentUat];
#else
    [[MLTestUtils sharedInstance] setEnvironment:MLEnvironmentDev];
#endif
    
    [MaxLeap setNetworkTimeoutInterval:60];
    [MLLogger setLogLevel:MLLogLevelWarning];
    [MaxLeap setApplicationId:ApplicationID clientKey:ClientKey site:MLSiteCN];
}

- (void)registerNotifications {
    UIUserNotificationSettings *pushsettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:pushsettings];
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
   
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - RemoteNotification
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

  
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if  (buttonIndex != alertView.cancelButtonIndex) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(YES),@"notification":@(YES)}];
    }
}

@end

