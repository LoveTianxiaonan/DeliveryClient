//
//  MLAMSettingViewController.m
//  MLAppMaker
//
//  Created by Michael on 5/23/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import "MLAMSettingViewController.h"
#import "AppDelegate.h"

@interface MLAMSettingViewController () <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSNumber *appleStoreID;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) NSString *phoneNumber;
@end

@implementation MLAMSettingViewController
#pragma mark Temporary Area

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"设置", nil);
    self.phoneNumber = @"400-158-0151";
    [self configureTableView];
    [self configureLogoutButton];
    NSString *bundldID = [[NSBundle mainBundle] bundleIdentifier];
    __weak typeof(self) weakSelf = self;
    [kSharedWebService fetchAppleStoreIDWithBundleID:bundldID completion:^(NSNumber *appleStoreID, NSError *error) {
        if (!error && appleStoreID.stringValue.length > 0) {
            weakSelf.appleStoreID = appleStoreID;
        }
    }];
}

#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration
- (void)configureTableView {
    [self.view addSubview:self.tableView];
    [self.tableView pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0f];
    [self.tableView registerClass:[MLAMTableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 50;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = kSeparatorLineColor;
    
    //[self.view addSubview:self.versionLabel];
    
    //[self.versionLabel pinToSuperviewEdges:JRTViewPinBottomEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0];
    //[self.versionLabel constrainToHeight:77];
}

- (void)configureLogoutButton {
    UIButton *logoutButton = [UIButton autoLayoutView];
    [logoutButton constrainToHeight:50];
    logoutButton.layer.cornerRadius = 2;
    logoutButton.layer.masksToBounds = YES;
    [self.view addSubview:logoutButton];
    [logoutButton pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:20];
    [logoutButton pinAttribute:NSLayoutAttributeCenterY toAttribute:NSLayoutAttributeCenterY ofItem:self.view withConstant:-60];
    [logoutButton setBackgroundImage:[UIImage imageWithColor:kButtonBGColor] forState:UIControlStateNormal];
    [logoutButton setTitle:NSLocalizedString(@"退出当前账号", nil) forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark- Actions
- (void)logoutAction:(id)sender {
    kSharedDeliveryPerson.appid = nil;
    kSharedDeliveryPerson.apiKey = nil;
    kSharedDeliveryPerson.userSession = nil;
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    AppDelegate *appDelegateTemp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegateTemp.window.rootViewController = loginVC;
}
#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method
#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    MLAMTableViewCell *cell = (MLAMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            cell.myTextLabel.text = NSLocalizedString(@"联系我们", nil);
            [cell addTopBorderWithColor:kSeparatorLineColor width:0.5];
        }
        
        if (row == 1) {
            cell.myTextLabel.text = NSLocalizedString(@"去评价", nil);
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.myTextLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    if (section == 1) {
        if (row == 0) {
            cell.myTextLabel.text = NSLocalizedString(@"退出当前账号", nil);
            cell.myTextLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell addBottomBorderWithColor:kSeparatorLineColor width:0.5];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.phoneNumber
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                                      otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
            [alertView show];
        }
        
        if (row == 1) {
            [self rateApp];
        }
    }
    
    if (section == 1) {
        kSharedDeliveryPerson.appid = nil;
        kSharedDeliveryPerson.apiKey = nil;
        kSharedDeliveryPerson.userSession = nil;
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        AppDelegate *appDelegateTemp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegateTemp.window.rootViewController = loginVC;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 80;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark- Private Methods
- (void)rateApp {
    NSString *nsStringToOpen = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@", self.appleStoreID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nsStringToOpen]];
}

- (void)aboutOur {
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *url = [NSString stringWithFormat:@"telprompt://%@",self.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
#pragma mark- Getter Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _tableView;
}

#pragma mark- Getter Setter
- (UILabel *)versionLabel {
    if (!_versionLabel) {
        UILabel *label = [UILabel autoLayoutView];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColorFromRGB(0x8F8F8F);
        label.font = [UIFont systemFontOfSize:12];
        
        label.numberOfLines = 0;
        NSString* string = NSLocalizedString(@"© 2010-2016 LeapCloud.cn 版权所有\n沪ICP备15041312号-4", nil);
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 18.f;
        style.maximumLineHeight = 18.f;
        style.alignment = NSTextAlignmentCenter;
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
        label.attributedText = [[NSAttributedString alloc] initWithString:string
                                                               attributes:attributtes];
        _versionLabel = label;
    }
    
    return _versionLabel;
}

#pragma mark- Helper Method

@end

@implementation MLAMTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    [self.contentView addSubview:self.myTextLabel];
    [self.myTextLabel pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinBottomEdge inset:0];
    [self.myTextLabel pinToSuperviewEdges:JRTViewPinRightEdge | JRTViewPinLeftEdge inset:25];
    
    return self;
}

- (UILabel *)myTextLabel {
    if (!_myTextLabel) {
        _myTextLabel = [UILabel autoLayoutView];
        _myTextLabel.font = [UIFont systemFontOfSize:17];
        _myTextLabel.textColor = UIColorFromRGB(0x444444);
    }
    
    return _myTextLabel;
}

@end
