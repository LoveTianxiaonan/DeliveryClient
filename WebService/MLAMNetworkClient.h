//
//  MLGMAccountManager+Convenience.h
//  MaxLeapGit
//
//  Created by Michael on 15/10/9.

#import <Foundation/Foundation.h>

#define kSharedNetworkClient [MLAMNetworkClient sharedInstance]

typedef void(^CompleteHanderBlock)(NSDictionary *responHeaderFields, NSInteger statusCode, id responseData, NSError *error);

@interface MLAMNetworkClient : NSObject

+ (MLAMNetworkClient *)sharedInstance;
- (NSURLRequest *)getRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)queryParameters;
- (NSURLRequest *)postRequestWithEndPoint:(NSString *)endPoint parameters:(id)postParameters;
- (NSURLRequest *)putRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)postParameters;
- (NSURLRequest *)deleteRequestWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)postParameters;

- (void)startRequest:(NSURLRequest *)request patternFile:(NSString *)patternFile completion:(CompleteHanderBlock)completion;
- (void)uploadRequest:(NSURLRequest *)request data:(NSData *)data completion:(CompleteHanderBlock)completion;
- (void)cancelAllDataTasksCompletion:(void(^)())completion;

@end
