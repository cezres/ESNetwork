//
//  ESRequestHandler.m
//  ESNetwork
//
//  Created by 翟泉 on 2016/11/8.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequestHandler.h"
#import <AFNetworking.h>
#import "ESHTTPRequestSerializer.h"
#import "ESHTTPResponseSerializer.h"
#import "ESRequest.h"

@interface ESRequestHandler ()

@property(strong, nonatomic, nonnull) AFHTTPSessionManager *HTTPSessionManager;

@end

@implementation ESRequestHandler

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _HTTPSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:NULL sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _HTTPSessionManager.requestSerializer = [ESHTTPRequestSerializer serializer];
        _HTTPSessionManager.responseSerializer = [ESHTTPResponseSerializer serializer];
    }
    return self;
}

- (NSURLSessionDataTask *)handleRequest:(ESRequest *)request {
    return [self handleRequestWithURLString:request.URLString Method:request.method parameters:request.parameters delegate:request];
}

- (NSURLSessionDataTask *)handleRequestWithURLString:(NSString *)URLString Method:(ESHTTPMethod)method parameters:(id)parameters delegate:(id<ESRequestHandlerDelegate>)delegate {
    if (![URLString hasPrefix:@"http"]) {
        URLString = [_baseURL stringByAppendingPathComponent:URLString];
    }
    if (method == ESHTTPMethodGet) {
        return [_HTTPSessionManager GET:URLString parameters:parameters progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [delegate requestHandleCompletionResponseObject:responseObject error:NULL];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [delegate requestHandleCompletionResponseObject:NULL error:error];
        }];
    }
    else if (method == ESHTTPMethodPost) {
        return [_HTTPSessionManager POST:URLString parameters:parameters progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [delegate requestHandleCompletionResponseObject:responseObject error:NULL];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [delegate requestHandleCompletionResponseObject:NULL error:error];
        }];
    }
    else {
        return NULL;
    }
}

#pragma mark get / set
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    _HTTPSessionManager.requestSerializer.timeoutInterval = timeoutInterval;
}
- (NSTimeInterval)timeoutInterval {
    return _HTTPSessionManager.requestSerializer.timeoutInterval;
}


@end
