//
//  MLAMOrderListViewController.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/24.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMOrderListViewController.h"
#import "MLAMOrderDeliveryTableViewCell.h"
@interface MLAMOrderListViewController ()<UITableViewDelegate, UITableViewDataSource,MLAMOrderDeliveryTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;
@property (strong, nonatomic) NSMutableArray *orders;
@end

@implementation MLAMOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureBottomView];
}

- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 190;
    
    __weak typeof(self) weakSelf = self;
    __block int page = 0;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 0;
        [kSharedWebService fetchOrdersWithState:self.orderState page:page completion:^(NSMutableArray *orders, BOOL didReachEnd, NSError *error) {
            [weakSelf.tableView.mj_header endRefreshing];
            weakSelf.tableView.mj_footer.hidden = didReachEnd;
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            } else {
                weakSelf.orders = orders;
                [weakSelf.tableView reloadData];
            }
            weakSelf.showEmptyTipHandler(weakSelf.orders.count == 0);
        }];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [kSharedWebService fetchOrdersWithState:self.orderState page:page+1 completion:^(NSMutableArray *orders, BOOL didReachEnd, NSError *error) {
            [weakSelf.tableView.mj_footer endRefreshing];
            weakSelf.tableView.mj_footer.hidden = didReachEnd;
            if (error) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
            }
            if (orders.count > 0) {
                page++;
                [weakSelf.orders addObjectsFromArray:orders];
                [weakSelf.tableView reloadData];
            }
        }];
    }];
    self.tableView.mj_footer.hidden = YES;
    [self.tableView.mj_header beginRefreshing];
}

- (void)configureBottomView {
    self.bottomViewHeightConstraint.constant = self.orderState == MLAMOrderStateNew?50:0;
    self.bottomView.hidden = self.orderState != MLAMOrderStateNew;
    [self.refreshButton setTitleColor:kDefaultTextColor forState:UIControlStateNormal];
    [self.refreshButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.refreshButton setBackgroundImage:[UIImage imageWithColor:kButtonBGColor] forState:UIControlStateHighlighted];
    [self.refreshButton setTitle:NSLocalizedString(@"刷新列表", nil) forState:UIControlStateNormal];
    [self.refreshButton setImage:ImageNamed(@"ic_refresh_normal") forState:UIControlStateNormal];
    self.refreshButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
}
- (void)loadData:(BOOL)animation {
    if (animation) {
        [self.tableView.mj_header beginRefreshing];
    }else {
        self.tableView.mj_header.refreshingBlock();
    }
}

- (BOOL)isEmptyResult {
    return self.orders.count == 0;
}
- (IBAction)refreshList:(id)sender {
    [self.tableView.mj_header beginRefreshing];
}
#pragma mark  - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.orders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLAMOrderDeliveryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MLAMOrderDeliveryTableViewCell"];
    cell.delegate = self;
    [cell configureOrder:self.orders[indexPath.section]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MLAMOrderDetailViewController *detailController = [MLAMOrderDetailViewController instantiateFromStoryboard];
    detailController.order = self.orders[indexPath.section];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

#pragma mark - MLAMOrderDeliveryTableViewCellDelegate
- (void)grabOrder:(UITableViewCell *)cell {
    [SVProgressHUD show];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    MLAMOrder *order = self.orders[indexPath.section];
    [kSharedWebService grabOrderWithOrderId:order.orderId completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        if (success) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"抢单成功", nil)];
        }else {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"该单已经被抢", nil)];
        }
        [self.orders removeObject:order];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO),@"currentOrderState":@(_orderState)}];
        self.showEmptyTipHandler(self.orders.count == 0);
    }];
}

- (void)giveupOrder:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [SVProgressHUD show];
    MLAMOrder *order = self.orders[indexPath.section];
    [kSharedWebService giveupOrderWithOrderId:order.orderId completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"放弃成功", nil)];
        [self.orders removeObject:order];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO),@"currentOrderState":@(_orderState)}];
        self.showEmptyTipHandler(self.orders.count == 0);
    }];
}

- (void)shippingOrder:(UITableViewCell *)cell {
    [SVProgressHUD show];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    MLAMOrder *order = self.orders[indexPath.section];
    [kSharedWebService shippingOrderWithOrderId:order.orderId completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"取货成功", nil)];
        [self.orders removeObject:order];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO),@"currentOrderState":@(_orderState)}];
        self.showEmptyTipHandler(self.orders.count == 0);
    }];
}

- (void)completedOrder:(UITableViewCell *)cell {
    [SVProgressHUD show];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    MLAMOrder *order = self.orders[indexPath.section];
    [kSharedWebService completedOrderWithOrderId:order.orderId completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"配送成功", nil)];
        [self.orders removeObject:order];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO),@"currentOrderState":@(_orderState)}];
        self.showEmptyTipHandler(self.orders.count == 0);
    }];
}
@end
