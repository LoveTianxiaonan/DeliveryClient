//
//  MLAMMapRouteViewController.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/28.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMMapRouteViewController.h"

@interface MLAMMapRouteViewController ()<MAMapViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *lowerButton;

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, strong) AMapNaviPoint *wayPoint;

@property (assign, nonatomic) float originalScale;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation MLAMMapRouteViewController
+ (instancetype)instantiateFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
    MLAMMapRouteViewController *VC = [sb instantiateViewControllerWithIdentifier:@"MLAMMapRouteViewController"];
    return VC;
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.mapView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1 green:247/255.f blue:247/255.f alpha:1];
    self.title = NSLocalizedString(@"路线", nil);
    [self configureButtons];
    [self initMapView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self displayMapDetailInfomation];
    });
}
- (void)configureButtons {
    self.centerButton.backgroundColor = kButtonBGColor;
    self.rightButton.backgroundColor = kButtonBGColor;
    self.centerButton.layer.cornerRadius = self.leftButton.layer.cornerRadius = self.rightButton.layer.cornerRadius = 2;
    self.centerButton.layer.masksToBounds = self.leftButton.layer.masksToBounds = self.rightButton.layer.masksToBounds = YES;
    [self.centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightButton setTitle:NSLocalizedString(@"取货", nil) forState:UIControlStateNormal];
    [self.leftButton setTitleColor:kDefaultTextColor forState:UIControlStateNormal];
    self.leftButton.backgroundColor = [UIColor whiteColor];
    self.leftButton.layer.borderWidth = 1;
    self.leftButton.layer.borderColor = kDefaultGrayColor.CGColor;
    [self.leftButton setTitle:NSLocalizedString(@"放弃", nil) forState:UIControlStateNormal];
    
    [self.locationButton setImage:ImageNamed(@"ic_map_reposition") forState:UIControlStateNormal];
    [self.plusButton setImage:ImageNamed(@"ic_map_boost") forState:UIControlStateNormal];
    [self.lowerButton setImage:ImageNamed(@"ic_map_shrink") forState:UIControlStateNormal];
    self.locationButton.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.plusButton.layer.borderColor = self.lowerButton.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.locationButton.layer.borderWidth = self.plusButton.layer.borderWidth = self.lowerButton.layer.borderWidth = 1.f;
    [self updateButtonState];
}

- (void)updateButtonState {
    [self.centerButton setTitle:self.order.orderState.integerValue==MLAMOrderStateNew?NSLocalizedString(@"抢单", nil):NSLocalizedString(@"确认送达", nil)
                       forState:UIControlStateNormal];
    self.leftButton.hidden = self.rightButton.hidden = self.order.orderState.integerValue!=MLAMOrderStateGotoTake;
    self.centerButton.hidden = self.order.orderState.integerValue==MLAMOrderStateGotoTake;
}

- (IBAction)centerButtonPressed:(id)sender {
    if (self.order.orderState.integerValue == MLAMOrderStateNew) {
        [SVProgressHUD show];
        [kSharedWebService grabOrderWithOrderId:self.order.orderId completion:^(BOOL success, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                return ;
            }
            if (success) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"抢单成功", nil)];
                self.order.orderState = @(MLAMOrderStateGotoTake);
                [self updateButtonState];
            }else {
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"该单已经被抢", nil)];
                execute_after_main_queue(.3f, ^(){
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO)}];
        }];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                        message:NSLocalizedString(@"确定已经送达?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                              otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
        alert.tag = 1;
        [alert show];
    }
}

- (IBAction)leftButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                    message:NSLocalizedString(@"确定要放弃此订单?", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                          otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alert.tag = 2;
    [alert show];
}

- (IBAction)rightButtonPressed:(id)sender {
    [SVProgressHUD show];
    [kSharedWebService shippingOrderWithOrderId:self.order.orderId completion:^(BOOL success, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            return ;
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"取货成功", nil)];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO)}];
        self.order.orderState = @(MLAMOrderStateInDelivery);
        [self updateButtonState];
    }];
}

- (IBAction)locationButtonPressed:(id)sender {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    [self.mapView setZoomLevel:self.originalScale animated:YES];
}

- (IBAction)lowerButtonPressed:(id)sender {
    [self.mapView setZoomLevel:self.mapView.zoomLevel*0.94f animated:YES];
}

- (IBAction)plusButtonPressed:(id)sender {
    [self.mapView setZoomLevel:self.mapView.zoomLevel/0.94f animated:YES];
}

- (void)initProperties {
    self.startPoint = [AMapNaviPoint locationWithLatitude:kSharedDeliveryPerson.latitude
                                                longitude:kSharedDeliveryPerson.longitude];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:self.order.receiverLatitude.doubleValue
                                                longitude:self.order.receiverLongitude.doubleValue];
    self.wayPoint = [AMapNaviPoint locationWithLatitude:self.order.mallLatitude.doubleValue
                                              longitude:self.order.mallLongitude.doubleValue];
}

- (void)initAnnotations
{
    NaviPointAnnotation *beginAnnotation = [[NaviPointAnnotation alloc] init];
    [beginAnnotation setCoordinate:CLLocationCoordinate2DMake(self.startPoint.latitude, self.startPoint.longitude)];
    beginAnnotation.navPointType = NaviPointAnnotationStart;
    [self.mapView addAnnotation:beginAnnotation];
    
    if (self.order.orderState.integerValue == MLAMOrderStateNew || self.order.orderState.integerValue == MLAMOrderStateGotoTake) {
        NaviPointAnnotation *wayAnnotation = [[NaviPointAnnotation alloc] init];
        [wayAnnotation setCoordinate:CLLocationCoordinate2DMake(self.wayPoint.latitude, self.wayPoint.longitude)];
        wayAnnotation.title = @"取货点";
        wayAnnotation.navPointType = NaviPointAnnotationWay;
        [self.mapView addAnnotation:wayAnnotation];
    }
    
    NaviPointAnnotation *endAnnotation = [[NaviPointAnnotation alloc] init];
    [endAnnotation setCoordinate:CLLocationCoordinate2DMake(self.endPoint.latitude, self.endPoint.longitude)];
    endAnnotation.title = @"送货点";
    endAnnotation.navPointType = NaviPointAnnotationEnd;
    [self.mapView addAnnotation:endAnnotation];
}

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [MAMapView autoLayoutView];
        self.mapView.showsUserLocation = YES;
        self.mapView.pausesLocationUpdatesAutomatically = NO;
        self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
        self.mapView.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.mapView.zoomLevel = 14;
        self.originalScale = 14;
        self.mapView.showsBuildings = NO;
        self.mapView.showsLabels = YES;
        self.mapView.showsCompass = NO;
        self.mapView.showsScale = NO;
        //self.mapView.rotateEnabled = NO;
        [self.mapView setDelegate:self];
        [self.view addSubview:self.mapView];
        [self.view sendSubviewToBack:self.mapView];
        [self.mapView pinToSuperviewEdges:JRTViewPinAllEdges inset:0];
        
        MAUserLocationRepresentation *custom = [MAUserLocationRepresentation new];
        custom.showsAccuracyRing = NO;
        custom.showsHeadingIndicator = YES;
        custom.image = ImageNamed(@"ic_map_directing");
        [self.mapView updateUserLocationRepresentation:custom];
        
    }
}

- (void)showNaviRoutes:(AMapNaviRoute *)naviRoute
{
    if (naviRoute == nil)
    {
        return;
    }
    
    //将路径显示到地图上
    AMapNaviRoute *aRoute = naviRoute;
    int count = (int)[[aRoute routeCoordinates] count];
    
    //添加路径Polyline
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < count; i++)
    {
        AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
        coords[i].latitude = [coordinate latitude];
        coords[i].longitude = [coordinate longitude];
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
    
    SelectableOverlay *selectablePolyline = [[SelectableOverlay alloc] initWithOverlay:polyline];
    selectablePolyline.selected = YES;
    [self.mapView addOverlay:selectablePolyline];
    free(coords);
}

- (void)showWalkRoute
{
    for (AMapNaviRoute *route in [MLAMNaviWalkManager sharedManager].naviRoutes) {
        NSInteger index = [[MLAMNaviWalkManager sharedManager].naviRoutes indexOfObject:route];
        [self showNaviRoutes:route];
        if (index == 0) {
            [self.mapView showAnnotations:self.mapView.annotations animated:NO];
            self.originalScale = self.mapView.zoomLevel;
            self.mapView.zoomLevel = self.originalScale*0.96;
        }
    }
    
    if ([MLAMNaviWalkManager sharedManager].naviRoutes.count == 0) {
        [self.mapView showAnnotations:self.mapView.annotations animated:NO];
        self.originalScale = self.mapView.zoomLevel;
        self.mapView.zoomLevel = self.originalScale*0.92;
    }
}

- (void)displayMapDetailInfomation {
    [self initProperties];
    [self initAnnotations];
    [self showWalkRoute];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[NaviPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"NaviPointAnnotationIdentifier";
        
        MAAnnotationView *pointAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (pointAnnotationView == nil)
        {
            pointAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:annotationIdentifier];
        }
        
        pointAnnotationView.canShowCallout = YES;
        pointAnnotationView.draggable      = NO;
        
        NaviPointAnnotation *navAnnotation = (NaviPointAnnotation *)annotation;
        if (navAnnotation.navPointType == NaviPointAnnotationUser) {
            pointAnnotationView.image = ImageNamed(@"ic_map_directing");
            pointAnnotationView.centerOffset = CGPointMake(0, -5);
            pointAnnotationView.enabled = NO;
        }else if (navAnnotation.navPointType == NaviPointAnnotationStart)
        {
            pointAnnotationView.image = nil;
            pointAnnotationView.enabled = NO;
            /*
            pointAnnotationView.image = [ImageNamed(@"ic_site_location") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            pointAnnotationView.imageView.tintColor = kButtonBGColor;
            pointAnnotationView.centerOffset = CGPointMake(0, -9);
            */
        }
        else if (navAnnotation.navPointType == NaviPointAnnotationEnd)
        {
            pointAnnotationView.image = ImageNamed(@"ic_delivery_map_send");
            pointAnnotationView.centerOffset = CGPointMake(0, -14);
        }else {
            pointAnnotationView.image = ImageNamed(@"ic_delivery_map_take");
            pointAnnotationView.centerOffset = CGPointMake(0, -14);
        }
        
        return pointAnnotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    MAAnnotationView *view = [self.mapView viewForAnnotation:userLocation];
    [view rotateWithRotationDegree:userLocation.heading.magneticHeading-self.mapView.rotationDegree];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[SelectableOverlay class]])
    {
        SelectableOverlay * selectableOverlay = (SelectableOverlay *)overlay;
        id<MAOverlay> actualOverlay = selectableOverlay.overlay;
        
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
        
        polylineRenderer.lineWidth = 4.f;
        polylineRenderer.strokeColor = selectableOverlay.isSelected ? selectableOverlay.selectedColor : selectableOverlay.regularColor;
        
        return polylineRenderer;
    }
    
    return nil;
}

- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 1) {
            [SVProgressHUD show];
            [kSharedWebService completedOrderWithOrderId:self.order.orderId completion:^(BOOL success, NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"配送成功", nil)];
                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO)}];
                execute_after_main_queue(.3f, ^(){
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }];
        }else {
            [SVProgressHUD show];
            [kSharedWebService giveupOrderWithOrderId:self.order.orderId completion:^(BOOL success, NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"放弃成功", nil)];
                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadOrderListNotificationName object:nil userInfo:@{@"animation":@(NO)}];
                self.order.orderState = @(MLAMOrderStateNew);
                [self updateButtonState];
            }];
        }
    }
}
@end
