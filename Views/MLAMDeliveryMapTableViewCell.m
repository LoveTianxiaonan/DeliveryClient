//
//  MLAMDeliveryMapTableViewCell.m
//  MLDelivery
//
//  Created by Miracle on 2017/4/27.
//  Copyright © 2017年 ML. All rights reserved.
//

#import "MLAMDeliveryMapTableViewCell.h"
@interface MLAMDeliveryMapTableViewCell()<MAMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, strong) AMapNaviPoint *wayPoint;

@property (nonatomic, assign) BOOL routeShowed;
@property (assign, nonatomic) BOOL shouldCalculatedRoute2;
@property (assign, nonatomic) long long lastUpdateLocationTime;

@property (strong, nonatomic) MLAMOrder *order;
@end
@implementation MLAMDeliveryMapTableViewCell
- (void)dealloc {
    self.mapView.delegate = nil;
    self.mapView = nil;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.backgroundColor = [UIColor colorWithRed:1 green:247/255.f blue:247/255.f alpha:1];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.infoView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    self.iconImageView.image = [ImageNamed(@"ic_site_location") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconImageView.tintColor = [UIColor whiteColor];
    [self initMapView];
    
    __weak typeof(self) wSelf = self;
    [MLAMNaviWalkManager sharedManager].calculateRouteSuccessHandler = ^(){
        [wSelf showNaviRoutes];
        if (wSelf.shouldCalculatedRoute2) {
            wSelf.shouldCalculatedRoute2 = NO;
            [wSelf calculateWalkRoute2];
        }
    };
    [MLAMNaviWalkManager sharedManager].calculateRouteFailureHandler = ^(){
        [wSelf.mapView showAnnotations:self.mapView.annotations animated:NO];
        wSelf.mapView.zoomLevel = self.mapView.zoomLevel*0.98;
    };
}

- (void)configureOrder:(MLAMOrder *)order {
    self.order = order;
    self.infoLabel.text = @"";
    
    self.startPoint = [AMapNaviPoint locationWithLatitude:kSharedDeliveryPerson.latitude
                                                longitude:kSharedDeliveryPerson.longitude];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:order.receiverLatitude.doubleValue longitude:order.receiverLongitude.doubleValue];
    self.wayPoint = [AMapNaviPoint locationWithLatitude:order.mallLatitude.doubleValue longitude:order.mallLongitude.doubleValue];
    
    if (order.orderState.integerValue == MLAMOrderStateNew || order.orderState.integerValue == MLAMOrderStateGotoTake) {
        CLLocation *orig = [[CLLocation alloc] initWithLatitude:self.startPoint.latitude  longitude:self.startPoint.longitude];
        CLLocation* dist = [[CLLocation alloc] initWithLatitude:self.wayPoint.latitude longitude:self.wayPoint.longitude];
        CLLocationDistance kilometers = [orig distanceFromLocation:dist]/1000;
        self.infoLabel.text = [NSString stringWithFormat:@"%@%.2f%@",NSLocalizedString(@"距离取货点", nil),kilometers,@"KM"];
    }else {
        CLLocation *orig = [[CLLocation alloc] initWithLatitude:self.startPoint.latitude  longitude:self.startPoint.longitude];
        CLLocation* dist = [[CLLocation alloc] initWithLatitude:self.endPoint.latitude longitude:self.endPoint.longitude];
        CLLocationDistance kilometers = [orig distanceFromLocation:dist]/1000;
        self.infoLabel.text = [NSString stringWithFormat:@"%@%.2f%@",NSLocalizedString(@"距离送货点", nil),kilometers,@"KM"];
    }
    
    if (self.lastUpdateLocationTime < kSharedDeliveryPerson.lastUpdateLocationTime) {
        [self.mapView removeOverlays:self.mapView.overlays];
        [[MLAMNaviWalkManager sharedManager].naviRoutes removeAllObjects];
        [self initAnnotations];
        if (order.orderState.integerValue == MLAMOrderStateNew || order.orderState.integerValue == MLAMOrderStateGotoTake) {
            self.shouldCalculatedRoute2 = YES;
            [self calculateWalkRoute1];
        }else {
            self.shouldCalculatedRoute2 = NO;
            [self calculateWalkRoute3];
        }
        self.lastUpdateLocationTime = kSharedDeliveryPerson.lastUpdateLocationTime;
    }
}


- (void)initAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
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
        self.mapView.showsBuildings = NO;
        self.mapView.showsLabels = YES;
        self.mapView.showsCompass = NO;
        self.mapView.showsScale = NO;
        self.mapView.rotateEnabled = NO;
        [self.mapView setDelegate:self];
        [self.bgView addSubview:self.mapView];
        [self.bgView sendSubviewToBack:self.mapView];
        [self.mapView pinToSuperviewEdges:JRTViewPinAllEdges inset:0];
        
        MAUserLocationRepresentation *custom = [MAUserLocationRepresentation new];
        custom.showsAccuracyRing = NO;
        custom.showsHeadingIndicator = YES;
        custom.image = ImageNamed(@"ic_map_directing");
        [self.mapView updateUserLocationRepresentation:custom];
    }
}

- (void)showNaviRoutes
{
    if ([MLAMNaviWalkManager sharedManager].naviRoute == nil)
    {
        return;
    }
    
    //将路径显示到地图上
    AMapNaviRoute *aRoute = [MLAMNaviWalkManager sharedManager].naviRoute;
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
    if (self.shouldCalculatedRoute2 || self.order.orderState.integerValue == MLAMOrderStateInDelivery) {
        [self.mapView showAnnotations:self.mapView.annotations animated:NO];
        self.mapView.zoomLevel = self.mapView.zoomLevel*0.98;
    }
}



- (void)calculateWalkRoute1
{
    [[MLAMNaviWalkManager sharedManager] calculateWalkRouteWithStartPoints:@[self.startPoint]
                                                                 endPoints:@[self.wayPoint]];
}

- (void)calculateWalkRoute2
{
    [[MLAMNaviWalkManager sharedManager] calculateWalkRouteWithStartPoints:@[self.wayPoint]
                                                                 endPoints:@[self.endPoint]];
}

- (void)calculateWalkRoute3
{
    [[MLAMNaviWalkManager sharedManager] calculateWalkRouteWithStartPoints:@[self.startPoint]
                                                                 endPoints:@[self.endPoint]];
    
    
    
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
            pointAnnotationView.enabled = NO;
            pointAnnotationView.image = ImageNamed(@"ic_map_directing");
            pointAnnotationView.centerOffset = CGPointMake(0, -5);
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

@end
