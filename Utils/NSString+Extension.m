//
//  NSString+Extension.m
//  MaxLeapGit
//
//  Created by Michael on 15/10/10.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "NSString+Extension.h"
#import <CoreImage/CoreImage.h>
#import<CommonCrypto/CommonDigest.h>

@implementation NSString (MFLMExtension)

+ (NSString *)getUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return uuidStr;
}

+ (NSString *)md5FromString:(NSString *)string {
    return [self md5FromData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)md5FromData:(NSData *)data {
    if (!data) {
        return nil;
    }
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, (CC_LONG)data.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (NSString *)getNonce {
    NSString *uuid = [self getUUID];
    return [[uuid substringToIndex:10] stringByReplacingOccurrencesOfString:@"-" withString:@""].lowercaseString;
}

- (NSString *)utf8AndURLEncode {
    return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (NSDictionary *)parametersFromQueryString {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (self) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:self];
        NSString *name = nil;
        NSString *value = nil;
        
        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];
            
            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];
            
            if (name && value)
            {
                [parameters setValue:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                              forKey:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    return parameters;
}

- (UIImage *)createRRcode {
    //1.实例化一个滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //1.1>设置filter的默认值
    //因为之前如果使用过滤镜，输入有可能会被保留，因此，在使用滤镜之前，最好恢复默认设置
    [filter setDefaults];
    
    //2将传入的字符串转换为NSData
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    //3.将NSData传递给滤镜（通过KVC的方式，设置inputMessage）
    [filter setValue:data forKey:@"inputMessage"];
    
    //4.由filter输出图像
    CIImage *outputImage = [filter outputImage];
    
    //5.将CIImage转换为UIImage
    UIImage *qrImage = [UIImage imageWithCIImage:outputImage];
    
    //6.返回二维码图像
    return qrImage;
}

- (NSString *)removeNonAsciiCharacter {
    NSMutableString *asciiCharacters = [NSMutableString string];
    for (NSInteger i = 32; i < 127; i++)  {
        [asciiCharacters appendFormat:@"%c", (char)i];
    }
    
    NSCharacterSet *nonAsciiCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:asciiCharacters] invertedSet];
    
    NSString *stringExcuteNonAscii = [[self componentsSeparatedByCharactersInSet:nonAsciiCharacterSet] componentsJoinedByString:@""];
    
    return stringExcuteNonAscii;
}

- (NSDate *)toDate {
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    }
    
    return [dateFormatter dateFromString:self];
}

- (NSUInteger)toAge {
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:self.toDate
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    return age;
}

- (NSURL *)toURL {
    return [NSURL URLWithString:self];
}

- (NSURLRequest *)toURLRequest {
    return [NSURLRequest requestWithURL:self.toURL];
}

- (NSURL *)toHTTPURL {
    NSString *urlString = self;
    
    if (![self hasPrefix:@"http:"] && ![self hasPrefix:@"https:"]){
    
        if([self hasPrefix:@"//"] ) {
            urlString = [@"https:" stringByAppendingString:self];
            
        }else  {
            
            urlString = [@"https://" stringByAppendingString:self];
        }
    }
    return [NSURL URLWithString:urlString];
}

- (NSString *)qiniuSize:(CGSize)size {
    int scale =[UIScreen mainScreen].scale;
    NSString *thumbileURLString = [NSString stringWithFormat:@"%@?imageView2/4/w/%d/h/%d", self, (int)size.width * scale, (int)size.height * scale];
    return thumbileURLString;
}

+ (NSString *)uuid {
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
    if (!uuid.length) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        uuid = [@(timeInterval) stringValue];
        [[NSUserDefaults standardUserDefaults] setObject:uuid  forKey:@"uuid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return uuid;
}

- (float)heightInFixedWidth:(CGFloat)fixedWidth andFont:(UIFont *)font lineSpace:(float)lineSpace {
    if (self.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = lineSpace;
        CGRect frame = [self boundingRectWithSize:CGSizeMake(fixedWidth, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName : paragraphStyle}
                                          context:nil];
        return frame.size.height + 1;
    } else {
        return 0;
    }
}

- (NSAttributedString *)decorateStringWithColor:(UIColor *)color range:(NSRange)range {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    return [attributedString copy];
}

- (BOOL)isMobileNumber {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:self] == YES)
        || ([regextestcm evaluateWithObject:self] == YES)
        || ([regextestct evaluateWithObject:self] == YES)
        || ([regextestcu evaluateWithObject:self] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString *)collapseSequenceOfWhiteSpaceToSingleCharacterAndTrimString {
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    NSString *theString = [filteredArray componentsJoinedByString:@" "];
    
    return theString;
}

- (BOOL)isCombinationOfLettersAndNumbers {
    NSString *reg = @"[A-Z0-9a-z]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    return [pred evaluateWithObject:self];
}

- (BOOL)isCombinationOfNumbersAndLetters {
    return ![self containsNumbersOnly] && [self containsNumbers];
}

- (BOOL)containsNumbersOnly {
    BOOL isNumericOnly = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:self];
    isNumericOnly = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isNumericOnly;
}

- (BOOL)containsNumbers {
    NSCharacterSet *digitNumbersSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    return [self rangeOfCharacterFromSet:digitNumbersSet].location != NSNotFound;
}

- (NSString *)simplifyAddress {
    NSString *storeInfo = [self stringByReplacingOccurrencesOfString:@"_0" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.length)];
    storeInfo = [storeInfo stringByReplacingOccurrencesOfString:@"_" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, storeInfo.length)];
    return storeInfo;
}

-(NSAttributedString *)customPriceWithMoneyCharacter:(NSString *)character normalAttribute:(NSDictionary *)normalAttribute highAttribute:(NSDictionary *)highAttribute{

    NSArray *arr = [self componentsSeparatedByString:@"."];
    NSString *price = self;
    NSString *price1 = nil;
    if (arr.count == 2) {
        price = arr[0];
        price1 = [NSString stringWithFormat:@".%@",arr[1]];
    }
    NSMutableAttributedString *priceString = [[NSMutableAttributedString alloc] initWithString:character attributes:normalAttribute];
    [priceString appendAttributedString:[[NSAttributedString alloc] initWithString:price attributes:highAttribute]];
    if (price1) {
        [priceString appendAttributedString:[[NSAttributedString alloc] initWithString:price1 attributes:normalAttribute]];
    }
    
    return priceString;
}

- (NSString *)displayAddressString {
    NSString *storeInfo = [self stringByReplacingOccurrencesOfString:@"_0"
                                                          withString:@""
                                                             options:NSCaseInsensitiveSearch
                                                               range:NSMakeRange(0, self.length)];
    return [storeInfo stringByReplacingOccurrencesOfString:@"_" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, storeInfo.length)];
}

@end
