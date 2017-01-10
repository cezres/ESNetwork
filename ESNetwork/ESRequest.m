//
//  ESRequest.m
//  ESNetwork
//
//  Created by 翟泉 on 2016/11/8.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequest.h"
#import <CommonCrypto/CommonDigest.h>

NSString * __MD5(NSString *str);

@interface ESRequest ()


@end

@implementation ESRequest

- (instancetype)init {
    if (self = [super init]) {
        _builtinHeaderEnable = YES;
        _builtinParameterEnable = YES;
        _priority = ESRequestPriorityDefault;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

+ (instancetype)request {
    return [[self alloc] init];
}

- (__kindof ESRequest *)startWithDelegate:(id<ESRequestDelegate>)delegate {
    _delegate = delegate;
    return [self start];
}

- (__kindof ESRequest *)startWithCompletionBlock:(ESRequestBlock)completionBlock {
    _completionBlock = completionBlock;
    return [self start];
}

- (__kindof ESRequest *)start {
    [self willStart];
    
    if ([self readCache]) {
        [self completed];
    }
    else {
        _task = [[ESRequestHandler sharedInstance] handleRequest:self];
    }
    return self;
}

- (ESRequest *)stop {
    [self.task cancel];
    return self;
}

- (NSURLSessionTaskState)state {
    return _task.state;
}


- (void)willStart {
    _dataFromCache = NO;
    _response = NULL;
    _responseObject = NULL;
    _error = NULL;
    _task = NULL;
}

- (void)completed {
    [self storeCache];
    [self.delegate requestCompletion:self];
    !_completionBlock ?: _completionBlock(self);
    _completionBlock = NULL;
}

#pragma mark - RequestHandlerDelegate
- (void)requestHandleCompletionResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject error:(NSError *)error {
    _response = response;
    _responseObject = responseObject;
    _error = error;
    [self completed];
}

#pragma mark - Cache

- (NSString *)groupName {
    return __MD5(self.URLString);
}

- (NSString *)identifier {
    if (self.parameters) {
        return __MD5([self.URLString stringByAppendingString:self.parameters.description]);
    }
    else {
        return self.groupName;
    }
}

- (void)storeCache {
    if (_dataFromCache) {
        return;
    }
    if (self.cacheTimeoutInterval <= 0 || !_responseObject) {
        return;
    }
    [[ESRequestCache sharedInstance] storeCachedJSONObjectForRequest:self];
}

- (BOOL)readCache {
    if (_mustFromNetwork) {
        return NO;
    }
    if (self.cacheTimeoutInterval <= 0) {
        return NO;
    }
    BOOL isTimeout;
    id cachedJSONObject = [[ESRequestCache sharedInstance] cachedJSONObjectForRequest:self isTimeout:&isTimeout];
    if (cachedJSONObject && !isTimeout) {
        _dataFromCache = YES;
        _responseObject = cachedJSONObject;
        return YES;
    }
    else {
        return NO;
    }
}

@end



NSString * __MD5(NSString *str) {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}


