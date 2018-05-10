//
//  MLAMMemberViewController.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/25.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMMemberViewController.h"
#import "MLAMSettingViewController.h"
@interface MLAMMemberViewController () <UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL pushOpen;
@end

@implementation MLAMMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"个人中心", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    self.pushOpen = YES;
    [kSharedWebService fetchPushNotificationSwitchStateWithCompletion:^(BOOL open, NSError *error) {
        if (error) {
            //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        self.pushOpen = open;
        [self.tableView reloadData];
    }];
    
    [kSharedWebService updateDeliverInfoWithCompletion:^(BOOL succeeded, NSError *error) {
        if (error) {
            //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchNotification:(UISwitch *)switchControl {
    //本地不修改推送开关 默认本地一直开启
    /*
    [[NSNotificationCenter defaultCenter] postNotificationName:@"switchRemoteNotification" object:nil userInfo:@{@"on":@(switchControl.isOn)}];
    [[NSUserDefaults standardUserDefaults] setBool:switchControl.isOn forKey:kNotificationSwitch];
    [[NSUserDefaults standardUserDefaults] synchronize];
    */
    self.pushOpen = switchControl.isOn;
    [kSharedWebService updatePushNotificationSwitchState:self.pushOpen completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"操作成功", nil)];
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark  - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section==0?4:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"headerTabelViewCellIdentifier"];
            UIImageView *bgImageView = [cell.contentView viewWithTag:1];
            UIImageView *iconImageView = [cell.contentView viewWithTag:2];
            UILabel *nameLabel = [cell.contentView viewWithTag:3];
            UILabel *phoneLabel = [cell.contentView viewWithTag:4];
            bgImageView.image = ImageNamed(@"bg_top");
            nameLabel.text = kSharedDeliveryPerson.userName;
            phoneLabel.text = kSharedDeliveryPerson.userPhone;
            [iconImageView sd_setImageWithURL:kSharedDeliveryPerson.userIcon.toHTTPURL placeholderImage:ImageNamed(@"logo_personal_center")];
        }else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            UILabel *titleLabel = [cell.contentView viewWithTag:1];
            titleLabel.text = NSLocalizedString(@"已完成的订单", nil);
        }else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell"];
            UILabel *titleLabel = [cell.contentView viewWithTag:1];
            UISwitch *switchAction = [cell.contentView viewWithTag:2];
            titleLabel.text = NSLocalizedString(@"新消息通知", nil);
            [switchAction setOn:self.pushOpen];
            if (switchAction.allTargets.count == 0) {
                [switchAction addTarget:self action:@selector(switchNotification:) forControlEvents:UIControlEventValueChanged];
            }
        }else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            UILabel *titleLabel = [cell.contentView viewWithTag:1];
            titleLabel.text = NSLocalizedString(@"关于我们", nil);
        }
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        UILabel *titleLabel = [cell.contentView viewWithTag:1];
        titleLabel.text = NSLocalizedString(@"设置", nil);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 158;
    }
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                
                break;
            case 1:
                [self performSegueWithIdentifier:@"showHistoryOrdersViewController" sender:nil];
                break;
            case 2:
                
                break;
            case 3:{
                MLAMAboutOurViewController *viewController = [[MLAMAboutOurViewController alloc] initWithNibName:@"MLAMAboutOurViewController" bundle:[NSBundle mainBundle]];
                [self.navigationController pushViewController:viewController animated:YES];
            }
                break;
            default:
                break;
        }
    }else {
        MLAMSettingViewController *settingViewController = [[MLAMSettingViewController alloc] init];
        [self.navigationController pushViewController:settingViewController animated:YES];
    }
}

@end
