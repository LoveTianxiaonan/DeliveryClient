//
//  LoginViewController.h
//  LiveVideo
//
//  Created by xiexufeng on 16/9/30.
//  Copyright © 2016年 xiexufeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPassWordButton;

@end
