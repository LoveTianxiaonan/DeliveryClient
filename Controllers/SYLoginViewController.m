//
//  LoginViewController.m
//  LiveVideo
//
//  Created by xiexufeng on 16/9/30.
//  Copyright © 2016年 xiexufeng. All rights reserved.
//

#import "SYLoginViewController.h"
#import "AppDelegate.h"

#define iPhonePlus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) : NO)


@interface SYLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *validateCodeViewHeightConstraints;
@property (weak, nonatomic) IBOutlet UIImageView *validateImageView;
@property (weak, nonatomic) IBOutlet UITextField *validateCodeTextField;
@property (nonatomic, copy) NSString *secret;
@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UIView *passcodeView;
@property (weak, nonatomic) IBOutlet UIView *validateCodeView;
@property (weak, nonatomic) IBOutlet UIImageView *backgrondImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acountViewTopConstraint;

@end

@implementation SYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneNumberTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.validateCodeTextField.returnKeyType = UIReturnKeyDone;
    self.validateCodeTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.validateCodeTextField.delegate = self;
    self.backgrondImageView.image = ImageNamed(@"bg_delivery_login");
    self.backgrondImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.showPassWordButton setImage:ImageNamed(@"btn_login_show_normal") forState:UIControlStateNormal];
    [self.showPassWordButton setImage:ImageNamed(@"btn_login_show_selected") forState:UIControlStateSelected];
    
    self.signInButton.layer.cornerRadius = 2;
    self.signInButton.layer.masksToBounds = YES;
    self.accountView.layer.cornerRadius=self.passcodeView.layer.cornerRadius=self.validateCodeView.layer.cornerRadius = 2;
    self.accountView.clipsToBounds=self.passcodeView.clipsToBounds=self.validateCodeView.clipsToBounds = YES;
    self.validateCodeViewHeightConstraints.constant = 0;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.signInButton.userInteractionEnabled = YES;
    self.signInButton.backgroundColor = kButtonBGColor;
    
    self.validateImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    
    tapGesture1.numberOfTapsRequired = 1;
    [self.validateImageView addGestureRecognizer:tapGesture1];
    
    if (iPhone5) {
        self.acountViewTopConstraint.constant = 180;
    }else if (iPhone6) {
        self.acountViewTopConstraint.constant = 220;
    }else if (iPhonePlus) {
        self.acountViewTopConstraint.constant = 240;
    }else if (iPhoneX) {
        self.acountViewTopConstraint.constant = 255;
    }
}

- (IBAction)changePassWordSecureTextEntry:(id)sender {
    self.showPassWordButton.selected = !self.showPassWordButton.selected;
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    NSString* text = self.passwordTextField.text;
    self.passwordTextField.text = @" ";
    self.passwordTextField.text = text;
}

- (void)tapGesture:(id)sender {
    [kSharedWebService obtainValidateCodeCompletion:^(NSString *secret, UIImage *validateImage, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"获取验证码失败!", nil)];
            return;
        }

        self.secret = secret;
        self.validateImageView.image = validateImage;
    }];
}

- (IBAction)loginButtonPressed:(id)sender {
    NSString *userName = self.phoneNumberTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (userName.length == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请输入手机号或邮箱", nil)];
        return;
    }
    
    if (password.length == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请输入密码", nil)];
        return;
    }
    
    [self.view endEditing:YES];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"登录中...", nil)];
    self.signInButton.enabled = NO;
    [kSharedWebService loginWithPhone:userName password:password validateCode:self.validateCodeTextField.text security:self.secret completion:^( BOOL succeeded, NSError *error) {
        self.signInButton.enabled = YES;
        if (error || !succeeded) {
            if (error.code == MLAMErrorTypeWrongValidationCode) {
                self.validateCodeViewHeightConstraints.constant = 50;
                [kSharedWebService obtainValidateCodeCompletion:^(NSString *secret, UIImage *validateImage, NSError *error) {
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"获取验证码失败", nil)];
                        return;
                    }
                    
                    self.secret = secret;
                    self.validateImageView.image = validateImage;
                }];
                if (self.validateCodeTextField.text.length == 0) {
                    [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
                }else {
                    [SVProgressHUD showErrorWithStatus:@"验证码不正确"];
                }
            } else if (error.code == MLAMErrorTypeWrongPassword) {
                self.validateCodeViewHeightConstraints.constant = 0;
                [SVProgressHUD showErrorWithStatus:@"密码不正确"];
                self.validateCodeTextField.text = nil;
                self.secret = nil;
            } else {
                self.validateCodeViewHeightConstraints.constant = 0;
                NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"登录失败:%@", nil), error.localizedDescription];
                [SVProgressHUD showErrorWithStatus:reason];
                self.validateCodeTextField.text = nil;
                self.secret = nil;
            }
            
            return;
        }
        
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"登录成功", nil)];
        SYTabBarViewController *mainVC = [SYTabBarViewController initTabbarVCFromNibFile];
        AppDelegate *appDelegateTemp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegateTemp.window.rootViewController = mainVC;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    if (textField == self.validateCodeTextField) {
//        if (ScreenRect.size.height < 570) {
//            [UIView animateWithDuration:.3 animations:^{
//                self.view.y = -70;
//            }];
//        }
//    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (textField == self.validateCodeTextField) {
//        if (ScreenRect.size.height < 570) {
//            [UIView animateWithDuration:.3 animations:^{
//                self.view.y = 0;
//            }];
//        }
//    }
}
@end
