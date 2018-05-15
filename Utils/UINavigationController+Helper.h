//
//  UINavigationController+Helper.h
//  DeliveryClient
//
//  Created by yao on 2018/5/15.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Helper)

+ (UINavigationController *)createNavVCFromViewController:(UIViewController *)viewController title:(NSString *)title normalImageName:(NSString *)image selectedImageName:(NSString *)selectedImage;

@end
