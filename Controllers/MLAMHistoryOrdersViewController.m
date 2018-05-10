//
//  MLAMHistoryOrdersViewController.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/26.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMHistoryOrdersViewController.h"
@interface MLAMHistoryOrdersViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UIImageView *tipImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel2;
@property (strong, nonatomic) UIView *historyPanel;
@property (strong, nonatomic) UIView *historyPanelBG;
@property (assign, nonatomic) float historyPanelHeight;
@property (strong, nonatomic) NSLayoutConstraint *panelTopConstraint;
@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) NSInteger month;
@property (strong, nonatomic) NSMutableArray *orders;
@end

@implementation MLAMHistoryOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipView.hidden = YES;
    self.tipImageView.image = ImageNamed(@"ic_delivery_indent");
    self.tipLabel1.text = NSLocalizedString(@"暂无完成订单", nil);
    self.tipLabel2.text = NSLocalizedString(@"快去抢单吧", nil);
    
    self.title = NSLocalizedString(@"已完成的订单", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"历史", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showHistoryPanel)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 110;
    
    __weak typeof(self) weakSelf = self;
    __block int page = 0;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 0;
        [kSharedWebService fetchHistoryOrdersWithYear:_year month:_month page:page completion:^(NSMutableArray *orders, BOOL didReachEnd, NSError *error) {
            [weakSelf.tableView.mj_header endRefreshing];
            weakSelf.tableView.mj_footer.hidden = didReachEnd;
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            } else {
                weakSelf.orders = orders;
                [weakSelf.tableView reloadData];
            }
            weakSelf.tipView.hidden = orders.count > 0;
        }];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [kSharedWebService fetchHistoryOrdersWithYear:_year month:_month page:page+1 completion:^(NSMutableArray *orders, BOOL didReachEnd, NSError *error) {
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
    
    
    [self.view addSubview:self.historyPanelBG];
    [self.historyPanelBG pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge|JRTViewPinBottomEdge inset:0];
    [self.historyPanelBG pinToSuperviewEdges:JRTViewPinTopEdge inset:64];
    self.historyPanelBG.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showHistoryPanel {
    if (self.historyPanelBG.hidden) {
        self.historyPanelBG.hidden = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [UIView animateWithDuration:.3f animations:^{
            self.panelTopConstraint.constant = 0;
            [self.historyPanelBG layoutSubviews];
        }completion:^(BOOL finished) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    }else {
        [self hideHistoryPanel];
    }
}
- (void)hideHistoryPanel {
    [UIView animateWithDuration:.3f animations:^{
        self.panelTopConstraint.constant = -self.historyPanelHeight;
        [self.historyPanelBG layoutSubviews];
        self.historyPanelBG.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        self.historyPanelBG.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        self.historyPanelBG.hidden = YES;
    }];
}
- (void)tapGestureRecognized:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self hideHistoryPanel];
    }
}
- (void)historyMonthPressed:(UIButton *)btn {
    self.year = btn.tag/100;
    self.month = btn.tag%100;
    [self hideHistoryPanel];
    [self.tableView.mj_header beginRefreshing];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
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
    orderNumberLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"订单号",nil),[(MLAMOrder*)self.orders[indexPath.row] billNum]];
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
    MLAMOrderDetailViewController *detailController = [MLAMOrderDetailViewController instantiateFromStoryboard];
    detailController.order = self.orders[indexPath.row];
    [self.navigationController pushViewController:detailController animated:YES];
}
#pragma mark - Helper
- (UIView *)historyPanel {
    if (_historyPanel == nil) {
        _historyPanel = [UIView autoLayoutView];
        _historyPanel.backgroundColor = [UIColor whiteColor];
        _historyPanel.userInteractionEnabled = YES;
        
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |
        NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
        NSInteger year = [dateComponent year];
        NSInteger month = [dateComponent month];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (month < 6) {
            NSMutableArray *months1 = [NSMutableArray array];
            for (NSInteger i = 1; i < month+1; i++) {
                [months1 addObject:@(i)];
            }
            [dic setObject:months1 forKey:@(year)];
            
            NSMutableArray *months2 = [NSMutableArray array];
            for (NSInteger i = 13-(6-month); i < 13; i++) {
                [months2 addObject:@(i)];
            }
            [dic setObject:months2 forKey:@(year-1)];
        }else {
            NSMutableArray *months = [NSMutableArray array];
            for (NSInteger i = month-5; i < month+1; i++) {
                [months addObject:@(i)];
            }
            [dic setObject:months forKey:@(year)];
        }
        float defaultHeight = 70;
        float gap = 10;
        float monthButtonWidth = (ScreenRect.size.width-2*gap)/6;
        float monthButtonHeight = 40;
        self.historyPanelHeight = defaultHeight*dic.allKeys.count;
        [_historyPanel constrainToHeight:self.historyPanelHeight];
        
        if (dic.allKeys.count == 2) {
            UIView *view = [UIView autoLayoutView];
            [_historyPanel addSubview:view];
            view.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [view constrainToHeight:0.5];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:10];
            [view centerInView:_historyPanel onAxis:NSLayoutAttributeCenterY];
        }
        
        for (NSNumber *yearN in dic.allKeys) {
            NSInteger indexY = year - yearN.integerValue;
            UILabel *title = [UILabel autoLayoutView];
            title.textColor = kDefaultGrayColor;
            title.font = [UIFont systemFontOfSize:14];
            title.text = [yearN stringValue];
            [_historyPanel addSubview:title];
            [title pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:10];
            [title pinToSuperviewEdges:JRTViewPinTopEdge inset:defaultHeight*indexY+10];
            
            for (NSNumber *monthN in dic[yearN]) {
                NSInteger indexM = [dic[yearN] count]-1 - [dic[yearN] indexOfObject:monthN];
                UIButton *button = [UIButton autoLayoutView];
                [button addTarget:self action:@selector(historyMonthPressed:) forControlEvents:UIControlEventTouchUpInside];
                button.titleLabel.font = [UIFont systemFontOfSize:15];
                button.tag = yearN.integerValue*100 + monthN.integerValue;
                [button setTitleColor:kDefaultTextColor forState:UIControlStateNormal];
                [button setTitleColor:kButtonBGColor forState:UIControlStateHighlighted];
                [button setTitle:[NSString stringWithFormat:@"%@%@",monthN,NSLocalizedString(@"月", nil)] forState:UIControlStateNormal];
                [button constrainToSize:CGSizeMake(monthButtonWidth, monthButtonHeight)];
                [_historyPanel addSubview:button];
                [button pinToSuperviewEdges:JRTViewPinTopEdge inset:defaultHeight*indexY+28];
                [button pinToSuperviewEdges:JRTViewPinLeftEdge inset:gap+monthButtonWidth*indexM];
            }
        }
    }
    return _historyPanel;
}
- (UIView *)historyPanelBG {
    if (_historyPanelBG == nil) {
        _historyPanelBG = [UIView autoLayoutView];
        _historyPanelBG.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tapGestureRecognized:)];
        [_historyPanelBG addGestureRecognizer:tapGesture];
        [_historyPanelBG addSubview:self.historyPanel];
        [self.historyPanel pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
        NSArray *constraints = [self.historyPanel pinToSuperviewEdges:JRTViewPinTopEdge inset:-self.historyPanelHeight];
        self.panelTopConstraint = constraints.firstObject;
    }
    return _historyPanelBG;
}
@end
