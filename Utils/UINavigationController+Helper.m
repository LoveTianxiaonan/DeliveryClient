//
//  UINavigationController+Helper.m
//  DeliveryClient
//
//  Created by yao on 2018/5/15.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "UINavigationController+Helper.h"

@implementation UINavigationController (Helper)

+ (UINavigationController *)createNavVCFromViewController:(UIViewController *)viewController title:(NSString *)title normalImageName:(NSString *)image selectedImageName:(NSString *)selectedImage {
    viewController.tabBarItem.image = [UIImage imageNamed:image];
    viewController.tabBarItem.selectedImage = [UIImage imageNamed:selectedImage];
    viewController.title = title;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    return nav;
}

@end
