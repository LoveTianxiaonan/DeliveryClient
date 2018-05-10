//
//  UIViewController+BSNSCPrsentViewControllerFromVisibleViewController.h
//  BSNShareCenter
//
//  Created by Jun Xia on 15/5/29.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (Extension)
- (UIViewController *)explorePresentedViewController;
- (void)presentVCFromVisibleVC:(UIViewController *)viewControllerToPresent completion:(void (^)(void))completion;
- (void)dismissVCFromVisibleVCAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissViewController:(id)sender;
- (void)popViewController:(id)sender;
@end
