//
//  UIViewController+Helper.m
//  DeliveryClient
//
//  Created by yao on 2018/5/15.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "UIViewController+Helper.h"

@implementation UIViewController (Helper)

- (UIViewController *)topViewController {
    static UIViewController *rootViewController = nil;
    if (rootViewController) {
        return rootViewController;
    }
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (keyWindow.windowLevel != UIWindowLevelNormal) {
        NSArray *allWindows = [[UIApplication sharedApplication] windows];
        for (UIWindow *window in allWindows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                keyWindow = window;
                break;
            }
        }
    }
    
    NSArray *windowSubViews = keyWindow.subviews;
    if (windowSubViews.count > 0) {
        UIView *rootView = [windowSubViews firstObject];
        id rootViewNextResponder = [rootView nextResponder];
        
        if ([rootViewNextResponder isKindOfClass:[UIViewController class]]) {
            rootViewController = rootViewNextResponder;
            
        } else if ([keyWindow respondsToSelector:@selector(rootViewController)] && keyWindow.rootViewController != nil) {
            rootViewController = keyWindow.rootViewController;
        }
    }
    
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    return rootViewController;
}

@end
