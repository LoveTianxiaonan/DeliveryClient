//
//  AppDelegate.m
//  DeliveryClient
//
//  Created by yao on 2018/5/9.
//  Copyright © 2018年 yao. All rights reserved.
//

#import "AppDelegate.h"
#import <MaxLeap/MLTestUtils.h>
@interface AppDelegate ()
@property(nonatomic, strong) CLLocationManager *lcManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kNotificationSwitch]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNotificationSwitch];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"LogoutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchRemoteNotification:) name:@"switchRemoteNotification" object:nil];
    if ([CLLocationManager authorizationStatus] < kCLAuthorizationStatusAuthorizedAlways) {
        self.lcManager = [CLLocationManager new];
        [_lcManager requestWhenInUseAuthorization];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self configureLeapCloud];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kNotificationSwitch]) {
        [self registerRemoteNotificationSettings];
    }
    
    [AMapServices sharedServices].apiKey = (NSString *)APIKey;
    [[UINavigationBar appearance] setBackgroundColor:kThemeColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:kThemeColor];
    
    
    if (kSharedDeliveryPerson.userSession.length > 0) {
        MainViewController *mainVC = [MainViewController instantiateFromStoryboard];
        UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController:mainVC];
        self.window.rootViewController = naVC;
    } else {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.window.rootViewController = loginVC;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
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


- (void)switchRemoteNotification:(NSNotification *)no {
    BOOL on = [no.userInfo[@"on"] boolValue];
    if (on) {
        [self registerRemoteNotifications];
    }else {
        [self unregisterRemoteNotifications];
    }
}

- (void)registerRemoteNotificationSettings {
    UIUserNotificationSettings *pushsettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:pushsettings];
}
- (void)registerRemoteNotifications {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
- (void)unregisterRemoteNotifications {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)logout {
    [kSharedDeliveryPerson setUserSession:nil];
    
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    AppDelegate *appDelegateTemp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegateTemp.window.rootViewController = loginVC;
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
    if (kSharedDeliveryPerson.userSession.length > 0) {
        UIViewController *nav = self.window.rootViewController;
        if ([nav isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)nav topViewController] isKindOfClass:[MainViewController class]]) {
            [(MainViewController *)[(UINavigationController*)nav topViewController] refreshLocationManagerState:nil];
        }
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [MLInstallation currentInstallation].badge = 0;
    [[MLInstallation currentInstallation] saveInBackgroundWithBlock:nil];
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
#if DEBUG
    [[MLInstallation currentInstallation] setDeviceTokenFromData:deviceToken forSandbox:YES];
#else
    [[MLInstallation currentInstallation] setDeviceTokenFromData:deviceToken forSandbox:NO];
#endif
    [[MLInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
    }];
    NSLog(@"deviceToken : %@: %@",deviceToken, [MLInstallation currentInstallation].installationId);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    completionHandler(UIBackgroundFetchResultNoData);
    NSLog(@"didReceiveRemoteNotificationUserInfo:\n %@",[userInfo jsonParameter]);
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [MLMarketingManager handlePushNotificationOpened:userInfo];
    }
    if (application.applicationState == UIApplicationStateActive) {
        NSString *title = @"";
        NSString *message = @"";
        id alertInfo = [userInfo valueForKeyPath:@"aps.alert"];
        if ([alertInfo isKindOfClass:[NSString class]]) {
            title = NSLocalizedString(@"推送", nil);
            message = alertInfo;
        }else if([alertInfo isKindOfClass:[NSDictionary class]]) {
            title = alertInfo[@"title"];
            message = alertInfo[@"body"];
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                                  otherButtonTitles:NSLocalizedString(@"确认", nil),nil];
        [alertView show];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO),@"notification":@(YES)}];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if  (buttonIndex != alertView.cancelButtonIndex) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(YES),@"notification":@(YES)}];
    }
}

@end

