//
//  MLAnalytics2.h
//  MaxLeap
//

#ifdef EXTENSION_IOS
#   import <MaxLeapExt/MLConstants.h>
#else
#   import <MaxLeap/MLConstants.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 *  MLSensorAnalytics provides methods to track events.
 */
@interface MLAnalytics2 : NSObject

+ (void)setHeadersWithDictionary:(NSDictionary *)dict;

/**
 *  @abstract Track an event without custom properties.
 *
 *  @discussion SDK will fill some reserved fields,
 *  like `_manufacturer`, `_model`, `_os`, `_os_version`, 
 *  `_app_version`, `_wifi`, `_screen_width`, `_screen_height`.
 *
 *  @param event The event name.
 */
+ (void)track:(NSString *)event;

/**
 *  @abstract Track an event with custom properties.
 *
 *  @discussion SDK will fill some reserved fields,
 *  like `_manufacturer`, `_model`, `_os`, `_os_version`,
 *  `_app_version`, `_wifi`, `_screen_width`, `_screen_height`.
 *  You can overide them by filling them into the properties argument.
 *
 *  @param event      The event name.
 *  @param properties Custom properties of the event.
 */
+ (void)track:(NSString *)event properties:(nullable NSDictionary<NSString*, id> *)properties;

/**
 *  @abstract Track an event with custom properties and custom event type.
 *
 *  @discussion SDK will fill some reserved fields,
 *  like `_manufacturer`, `_model`, `_os`, `_os_version`,
 *  `_app_version`, `_wifi`, `_screen_width`, `_screen_height`.
 *  You can overide them by filling them into the properties argument.
 *
 *  @param event      The event name
 *  @param properties The event custom properties
 *  @param type       The custom event type
 */
+ (void)track:(NSString *)event properties:(nullable NSDictionary<NSString*, id> *)properties type:(NSString *)type;

/**
 *  @abstract Track an event. All event fields need to be filled by yourself.
 *
 *  @param event The event object.
 */
+ (void)enqueueEvent:(NSDictionary *)event;

@end

NS_ASSUME_NONNULL_END
