//
//  SYCompleteViewController.m
//  DeliveryClient
//
//  Created by yao on 2018/5/15.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "SYCompleteViewController.h"

@interface SYCompleteViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (nonatomic, strong) NSMutableArray *orders;

@end

@implementation SYCompleteViewController

+ (instancetype)initCompleteVCFromNibFile {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SYCompleteViewController *VC = [sb instantiateViewControllerWithIdentifier:@"SYCompleteViewController"];
    return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"已完成订单";
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
        [kSharedWebService fetchHistoryOrdersWithYear:1 month:1 page:page completion:^(NSMutableArray *orders, BOOL didReachEnd, NSError *error) {
            [weakSelf.tableView.mj_header endRefreshing];
            weakSelf.tableView.mj_footer.hidden = didReachEnd;
            weakSelf.emptyLabel.hidden = orders.count > 0;
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            } else {
                weakSelf.orders = orders;
                [weakSelf.tableView reloadData];
            }
        }];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [kSharedWebService fetchHistoryOrdersWithYear:1 month:1 page:page+1 completion:^(NSMutableArray *orders, BOOL didReachEnd, NSError *error) {
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UILabel *orderNumberLabel = [cell.contentView viewWithTag:1];
    UILabel *timeLabel = [cell.contentView viewWithTag:2];
    UILabel *deliverPriceTitleLabel = [cell.contentView viewWithTag:3];
    UILabel *orderPriceTitleLabel = [cell.contentView viewWithTag:4];
    UILabel *deliverPriceLabel = [cell.contentView viewWithTag:5];
    UILabel *orderPriceLabel = [cell.contentView viewWithTag:6];
    deliverPriceLabel.textColor = orderPriceLabel.textColor = kHighlightColor;
    NSDecimalNumber *fen = [NSDecimalNumber decimalNumberWithString:@"100"];
    orderNumberLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"订单号",nil),[(SYOrder*)self.orders[indexPath.row] billNum]];
    timeLabel.text = [self.orders[indexPath.row] createdAt].detailedHumanDateString;
    deliverPriceTitleLabel.text = NSLocalizedString(@"配送费：", nil);
    orderPriceTitleLabel.text = NSLocalizedString(@"实付总价：", nil);
    deliverPriceLabel.text = [NSString stringWithFormat:@"￥%@",[[[self.orders[indexPath.row] freightFee] decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
    orderPriceLabel.text = [NSString stringWithFormat:@"￥%@",[[[self.orders[indexPath.row] realPrice] decimalNumberByDividingBy:fen] twoPlaceDecimalString]];
    [cell addBottomBorderWithColor:kSeparatorLineColor width:0.5];
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

@end
