//
//  MLTestUtils.h
//  ILSMaxLeap
//
//  Created by Sun Jin on 12/29/15.
//  Copyright © 2015 leap. All rights reserved.
//

#ifdef EXTENSION_IOS
#   import <MaxLeapExt/MLConstants.h>
#else
#   import <MaxLeap/MLConstants.h>
#endif

typedef NS_ENUM(NSInteger, MLEnvironment) {
    MLEnvironmentProd,
    MLEnvironmentDev,
    MLEnvironmentUat
};

@interface MLTestUtils : NSObject

@property (nonatomic) MLEnvironment environment;
@property (nonatomic) BOOL useHttps;
- (void)setEnvironmentWithString:(nullable NSString *)environment;

+ (nonnull instancetype)sharedInstance;

@end


typedef MLTestUtils MaxLeapSDKEnvironment;

