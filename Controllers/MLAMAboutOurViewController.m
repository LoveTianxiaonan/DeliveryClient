//
//  MLAMAboutOurViewController.m
//  MLAppMaker
//
//  Created by Michael on 5/23/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import "MLAMAboutOurViewController.h"

#define kDefaultCopyrightCompanyName    @"© 2010-2017 LeapCloud.cn 版权所有\n沪ICP备15041312号-4"

@interface MLAMAboutOurViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLable;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (nonatomic, strong) NSString *serviceString;//服务条款
@property (nonatomic, strong) NSString *lawString;//免责声明

@end

@implementation MLAMAboutOurViewController

#pragma mark Temporary Area

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"关于我们", nil);
    self.bgImageView.image = ImageNamed(@"bg_about_us");
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage *image = ImageNamed(@"AppIcon40x40");
    self.logoImageView.image = image;
    self.logoImageView.backgroundColor = kSeparatorLineColor;
    self.logoImageView.layer.cornerRadius = 4;
    self.logoImageView.layer.masksToBounds = YES;
    
    self.versionLabel.textInsets = UIEdgeInsetsMake(6, 12, 6, 12);
    self.versionLabel.text = [@"v" stringByAppendingString:kAppVersionIdentifier];
    self.versionLabel.font = [UIFont systemFontOfSize:14];
    self.versionLabel.layer.borderColor = kDefaultGrayColor.CGColor;
    self.versionLabel.layer.borderWidth = 0.5;
    self.versionLabel.layer.cornerRadius = 12;
    self.versionLabel.layer.masksToBounds = YES;
    
    NSString *sloganString = @"力谱云配送";
    self.introductionLabel.text = sloganString.length > 0 ? sloganString : kAppName;    
    self.rightLabel.text = kDefaultCopyrightCompanyName;
    
    self.infoLable.text = NSLocalizedString(@"(大商城)", nil);
    self.infoLable.textColor = kDefaultTextColor;
}

#pragma mark- Override Parent Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark- SubViews Configuration

#pragma mark- Actions

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

@end
