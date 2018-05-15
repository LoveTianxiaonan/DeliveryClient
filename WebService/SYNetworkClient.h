//
//  SYNetworkClient.h
//  DeliveryClient
//
//  Created by yao on 2018/5/14.
//  Copyright © 2018年 ML. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSharedNetworkClient [SYNetworkClient sharedInstance]

typedef void(^CompleteHanderBlock)(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error);

@interface SYNetworkClient : NSObject

+ (SYNetworkClient *)sharedInstance;
- (NSURLRequest *)getRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)queryParameters;
- (NSURLRequest *)postRequestWithEndPoint:(NSString *)endPoint parameters:(id)postParameters;
- (NSURLRequest *)putRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)postParameters;
- (NSURLRequest *)deleteRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)postParameters;

- (void)startRequest:(NSURLRequest *)request patternFile:(NSString *)patternFile completion:(CompleteHanderBlock)completion;
- (void)uploadRequest:(NSURLRequest *)request data:(NSData *)data completion:(CompleteHanderBlock)completion;
- (void)cancelAllDataTasksCompletion:(void(^)())completion;

@end
