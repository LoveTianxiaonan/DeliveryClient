//
//  MLAMUtils.h
//  MLAMUtils
//
//  Created by Michael on 1/17/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __OBJC__
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "NSString+Extension.h"
#import "NSArray+Extension.h"
#import "NSBundle+Extension.h"
#import "NSDictionary+Extension.h"
#import "NSString+Extension.h"
#include "UIBarButtonItem+Extension.h"
#import "UIImage+Extension.h"
#import "UIView+CustomBorder.h"
#import "UIView+FrameAccessor.h"
#import "UIView+MFLMSnapshot.h"
#import "NSManagedObjectContext+ScratchContext.h"
#import "UITextView+Placeholder.h"
#import "TRVSURLSessionOperation.h"
#import "NSOperationQueue+Completion.h"
#import "UIViewController+Extension.h"
#import "MKMapView+Extension.h"
#import "UIButton+Extension.h"
#import "NSDecimalNumber+Extension.h"
#import "UITabBarItem+MLAMExtension.h"
#import "MLAMZoneCodeConvertToProvince.h"
#import "UIAlertController+Window.h"
#import "UIColor+MLPFlatColors.h"

#endif

#define SAFE_STRING(string) string ?: @""
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil

#define BLOCK_SAFE_ASY_RUN_MainQueue(block, ...) block ? dispatch_async(dispatch_get_main_queue(), ^{\
BLOCK_SAFE_RUN(block,__VA_ARGS__); \
}): nil

#define BLOCK_SAFE_ASY_RUN_GlobalQueue(block, ...) block ? dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){\
BLOCK_SAFE_RUN(block,__VA_ARGS__); \
}): nil
