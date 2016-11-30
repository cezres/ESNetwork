//
//  ESRequestHandler.h
//  ESNetwork
//
//  Created by 翟泉 on 2016/11/8.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ESHTTPMethod) {
    ESHTTPMethodGet,
    ESHTTPMethodPost,
};

@class ESRequest;

@protocol ESRequestHandlerDelegate <NSObject>

/**
 *  请求完成后回调
 *
 *  @param responseObject <#responseObject description#>
 *  @param error          <#error description#>
 */
- (void)requestHandleCompletionResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject error:(NSError *)error;

@end



@interface ESRequestHandler : NSObject

/**
 *  请求超时时间
 */
@property (assign, nonatomic) NSTimeInterval timeoutInterval;

@property (strong, nonatomic) NSURL *baseURL;

@property (strong, nonatomic, readonly) NSDictionary<NSString *, id> *builtinParameters;
@property (strong, nonatomic, readonly) NSDictionary<NSString *, NSString *> *builtinHeaders;

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)handleRequest:(ESRequest *)request;

- (void)setValue:(NSString *)value forBuiltinParameterField:(NSString *)field;
- (void)setValue:(NSString *)value forBuiltinHeaderField:(NSString *)field;

@end
