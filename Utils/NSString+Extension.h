//
//  NSString+Extension.h
//  MaxLeapGit
//
//  Created by Michael on 15/10/10.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
- (BOOL)isCombinationOfLettersAndNumbers;
- (BOOL)isCombinationOfNumbersAndLetters;

+ (NSString *)getUUID;
+ (NSString *)uuid;
+ (NSString *)md5FromString:(NSString *)string;
+ (NSString *)getNonce;
- (NSDictionary *)parametersFromQueryString;
- (NSString *)utf8AndURLEncode;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)removeNonAsciiCharacter;
- (NSDate *)toDate;
- (NSUInteger)toAge;
- (NSURL *)toURL;
- (NSURLRequest *)toURLRequest;
- (NSURL *)toHTTPURL; // 如果没有http或者https前缀，则会追加https://前缀
- (NSString *)qiniuSize:(CGSize)size;

- (float)heightInFixedWidth:(CGFloat)fixedWidth andFont:(UIFont *)font lineSpace:(float)lineSpace;
- (NSAttributedString *)decorateStringWithColor:(UIColor *)color range:(NSRange)range;
- (BOOL)isMobileNumber;
- (NSString *)collapseSequenceOfWhiteSpaceToSingleCharacterAndTrimString;
- (NSString *)qiniuSize:(CGSize)size;
- (NSString *)displayAddressString;


/**
 * 使用需要导入 #import <CoreImage/CoreImage.h>
 */
- (UIImage *)createRRcode;

- (NSString *)simplifyAddress;

-(NSAttributedString *)customPriceWithMoneyCharacter:(NSString *)character normalAttribute:(NSDictionary *)normalAttribute highAttribute:(NSDictionary *)highAttribute;
@end
