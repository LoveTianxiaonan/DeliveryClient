//
//  WaitTakeViewController.m
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "SYWaitTakeViewController.h"

@interface SYWaitTakeViewController ()<UITableViewDelegate,UITableViewDataSource,MLAMOrderDeliveryTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) NSMutableArray *orders;

@end

@implementation SYWaitTakeViewController

+ (instancetype)initWaitTakeVCFromNibFile {
    SYWaitTakeViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SYWaitTakeViewController"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configTableView];
}

- (NSMutableArray *)orders {
    if (!_orders) {
        _orders = [NSMutableArray new];
    }
    return _orders;
}

#pragma mark - UI Config

- (void)configTableView {
    self.tableView.estimatedRowHeight = 190.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    MJWeakSelf
    __block int page = 0;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 0;
        [kSharedWebService fetchOrdersWithState:SYOrderStateGotoTake page:page completion:^(NSMutableArray *orders, BOOL didReachEnd, NSError *error) {
             weakSelf.emptyLabel.hidden = orders.count > 0;
            [weakSelf.tableView.mj_header endRefreshing];
            weakSelf.tableView.mj_footer.hidden = didReachEnd;
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            } else {
                weakSelf.orders = orders;
                [weakSelf.tableView reloadData];
            }
        }];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [kSharedWebService fetchOrdersWithState:SYOrderStateGotoTake page:page+1 completion:^(NSMutableArray *orders, BOOL didReachEnd, NSError *error) {
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

#pragma mark - UITableViewDelegate UITableViewDataSource

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
    SYOrderDetailViewController *detailVC = [SYOrderDetailViewController initOrderDetailVCFromNibFile];
    detailVC.order = self.orders[indexPath.section];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - MLAMOrderDeliveryTableViewCellDelegate

- (void)giveupOrder:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [SVProgressHUD show];
    SYOrder *order = self.orders[indexPath.section];
    [kSharedWebService giveupOrderWithOrderId:order.orderId completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"放弃成功", nil)];
        [self.orders removeObject:order];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
    }];
}

- (void)shippingOrder:(UITableViewCell *)cell {
    [SVProgressHUD show];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SYOrder *order = self.orders[indexPath.section];
    [kSharedWebService shippingOrderWithOrderId:order.orderId completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"取货成功", nil)];
        [self.orders removeObject:order];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
    }];
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
