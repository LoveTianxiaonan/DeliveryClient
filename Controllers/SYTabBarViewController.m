//
//  SYTabBarViewController.m
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "SYTabBarViewController.h"

@interface SYTabBarViewController ()

@end

@implementation SYTabBarViewController

+ (instancetype)initTabbarVCFromNibFile {
    SYTabBarViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SYTabBarViewController"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];
}

- (void)setupViewControllers {
    UINavigationController *newOrderNav = [UINavigationController createNavVCFromViewController:[SYNewOrderViewController initNewOrderVCFromNibFile] title:@"新订单" normalImageName:@"ic_forum_add" selectedImageName:@"ic_forum_add"];
    UINavigationController *waitTakeNav = [UINavigationController createNavVCFromViewController:[SYWaitTakeViewController initWaitTakeVCFromNibFile] title:@"待取货" normalImageName:@"small_mall" selectedImageName:@"small_mall"];
    UINavigationController *distributionNav = [UINavigationController createNavVCFromViewController:[SYDistributionViewController initDistributionVCFromNibFile] title:@"配送中" normalImageName:@"ic_logistics_map" selectedImageName:@"ic_logistics_map"];
    UINavigationController *settingNav = [UINavigationController createNavVCFromViewController:[SYSettingViewController initSettingVCFromNibFile] title:@"设置" normalImageName:@"ic_home_spell" selectedImageName:@"ic_home_spell"];
    NSArray *viewControllers = [NSArray arrayWithObjects:newOrderNav,waitTakeNav,distributionNav,settingNav, nil];
    [self setViewControllers:viewControllers animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
