//
//  SYDeliveryPerson.m
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import "SYDeliveryPerson.h"

@interface SYDeliveryPerson() <CLLocationManagerDelegate,MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locatinManager;

@end

@implementation SYDeliveryPerson

+ (SYDeliveryPerson *)sharedDeliveryPerson {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        SYDeliveryPerson *person = [SYDeliveryPerson new];
        return person;
    });
}

- (instancetype)init {
    if (self = [super init]) {
        [self createLocationManager];
    }
    return self;
}

- (void)setUserSession:(NSString *)userSession {
    [[NSUserDefaults standardUserDefaults] setObject:userSession forKey:@"userSession"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setAppid:(NSString *)appid {
    [[NSUserDefaults standardUserDefaults] setObject:appid forKey:@"appid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setApiKey:(NSString *)apiKey {
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:@"apiKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setUserName:(NSString *)userName {
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setUserIcon:(NSString *)userIcon {
    [[NSUserDefaults standardUserDefaults] setObject:userIcon forKey:@"userIcon"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setUserPhone:(NSString *)userPhone {
    [[NSUserDefaults standardUserDefaults] setObject:userPhone forKey:@"userPhone"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSysUserId:(NSString *)sysUserId {
    [[NSUserDefaults standardUserDefaults] setObject:sysUserId forKey:@"sysUserId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setObjectId:(NSString *)objectId {
    [[NSUserDefaults standardUserDefaults] setObject:objectId forKey:@"objectId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userSession {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"userSession"];
}
- (NSString *)appid {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"appid"];
}
- (NSString *)apiKey {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"apiKey"];
}

- (NSString *)userName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
}
- (NSString *)userPhone {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"userPhone"];
}
- (NSString *)userIcon {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"userIcon"];
}
- (NSString *)sysUserId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"sysUserId"];
}
- (NSString *)objectId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"objectId"];
}

- (void)createLocationManager {
    self.mapView = [MAMapView autoLayoutView];
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.delegate = self;
}

- (void)updateCurrentLocationToServer {
    [kSharedWebService updateLocation:self.latitude longitude:self.longitude];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    self.latitude = latitude;
    self.longitude = longitude;
    
    if ([[NSDate date] timeIntervalSince1970] - self.lastUpdateLocationTime > 10) {
        [kSharedWebService updateLocation:latitude longitude:longitude];
    }
    self.lastUpdateLocationTime = (long long)[[NSDate date] timeIntervalSince1970];
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation) {
        CLLocationDegrees latitude = userLocation.location.coordinate.latitude;
        CLLocationDegrees longitude = userLocation.location.coordinate.longitude;
        self.latitude = latitude;
        self.longitude = longitude;
        
        if ([[NSDate date] timeIntervalSince1970] - self.lastUpdateLocationTime > 10) {
            [kSharedWebService updateLocation:latitude longitude:longitude];
        }
        self.lastUpdateLocationTime = (long long)[[NSDate date] timeIntervalSince1970];
    }
}

@end
