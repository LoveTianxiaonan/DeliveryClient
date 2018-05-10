//
//  MLAMViewControllerPresentHelper.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/25.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMViewControllerPresentHelper.h"

@implementation MLAMViewControllerPresentHelper
+ (UIViewController *)topViewController {
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
