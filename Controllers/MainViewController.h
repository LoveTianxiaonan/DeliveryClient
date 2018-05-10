//
//  MainViewController.h
//  MLDelivery
//
//  Created by Miracle on 2017/4/5.
//  Copyright © 2017年 ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
+ (instancetype)instantiateFromStoryboard;
- (void)refreshLocationManagerState:(NSTimer *)timer;
@end
