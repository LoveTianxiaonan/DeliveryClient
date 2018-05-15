//
//  SYDeliveryPerson.h
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSharedDeliveryPerson [SYDeliveryPerson sharedDeliveryPerson]

@interface SYDeliveryPerson : NSObject

@property (nullable, nonatomic, copy) NSString *appid;
@property (nullable, nonatomic, copy) NSString *apiKey;
@property (nullable, nonatomic, copy) NSString *userSession;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, copy) NSString *userPhone;
@property (nullable, nonatomic, copy) NSString *userIcon;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *sysUserId;
@property (nullable, nonatomic, strong) NSArray *productCustomFields;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) long long lastUpdateLocationTime;

+ (SYDeliveryPerson * _Nonnull )sharedDeliveryPerson;
- (void)createLocationManager;
- (void)updateCurrentLocationToServer;

@end
