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
    
    
    NSString *URLString = request.URLString;
    NSObject *parameters = request.parameters;
    [self pretreatmentRequest:&URLString inoutParameters:&parameters];
    URLString = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
    
    /// 添加内置的请求参数
    if (request.builtinParameterEnable) {
        parameters = [self appendBuiltinParametersForParameters:parameters];
    }
    
    NSError *serializationError = nil;
    NSMutableURLRequest *urlRequest = [self.HTTPSessionManager.requestSerializer requestWithMethod:[self HTTPMethod:request.method] URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        [request requestHandleCompletionResponse:NULL responseObject:NULL error:serializationError];
        return nil;
    }
    
    /// 添加内置的请求头
    if (request.builtinHeaderEnable) {
        [self appendBuiltinHeadersForRequest:urlRequest];
    }
    
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.HTTPSessionManager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [request requestHandleCompletionResponse:(NSHTTPURLResponse *)response responseObject:responseObject error:error];
    }];
    
    
    if (request.priority == ESRequestPriorityLow) {
        dataTask.priority = NSURLSessionTaskPriorityLow;
    }
    else if (request.priority == ESRequestPriorityHigh) {
        dataTask.priority = NSURLSessionTaskPriorityHigh;
    }
    else {
        dataTask.priority = NSURLSessionTaskPriorityDefault;
    }
    
    [dataTask resume];
    
    return dataTask;
}

#pragma mark get / set
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    _HTTPSessionManager.requestSerializer.timeoutInterval = timeoutInterval;
}
- (NSTimeInterval)timeoutInterval {
    return _HTTPSessionManager.requestSerializer.timeoutInterval;
}

- (void)setValue:(NSString *)value forBuiltinHeaderField:(NSString *)field {
    if (!_builtinHeaders) {
        _builtinHeaders = [NSMutableDictionary dictionary];
    }
    [_builtinHeaders setValue:value forKey:field];
}
- (void)setValue:(NSString *)value forBuiltinParameterField:(NSString *)field {
    if (!_builtinParameters) {
        _builtinParameters = [NSMutableDictionary dictionary];
    }
    [_builtinParameters setValue:value forKey:field];
}

#pragma mark help

- (void)appendBuiltinHeadersForRequest:(NSMutableURLRequest *)request {
    [self.builtinHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![request valueForHTTPHeaderField:key]) {
            [request setValue:obj forHTTPHeaderField:key];
        }
    }];
}

- (id)appendBuiltinParametersForParameters:(id)parameters {
    if (!parameters) {
        return self.builtinParameters;
    }
    else if ([parameters isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *parametersDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [self.builtinParameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![parametersDict objectForKey:key]) {
                [parametersDict setObject:obj forKey:key];
            }
        }];
        parameters = [parametersDict copy];
    }
    else if ([parameters isKindOfClass:[NSArray class]]) {
        NSMutableArray *parametersArray = [NSMutableArray arrayWithArray:parameters];
        [self.builtinParameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            BOOL has = NO;
            for (NSString *string in parameters) {
                if ([string hasPrefix:[NSString stringWithFormat:@"%@=", key]]) {
                    has = YES;
                }
            }
            if (!has) {
                [parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
            }
        }];
        parameters = [parametersArray copy];
    }
    else if ([parameters isKindOfClass:[NSString class]]) {
        NSMutableString *parametersString = [NSMutableString stringWithString:parameters];
        [self.builtinParameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([parameters rangeOfString:[NSString stringWithFormat:@"%@=", key]].length) {
                return;
            }
            if ([parametersString length]) {
                [parametersString appendFormat:@"&%@=%@", key, obj];
            }
            else {
                [parametersString appendFormat:@"%@=%@", key, obj];
            }
        }];
        parameters = [parametersString copy];
    }
    return parameters;
}

- (NSString *)HTTPMethod:(ESHTTPMethod)method {
    NSString *result;
    if (method == ESHTTPMethodGet) {
        result = @"GET";
    }
    else if (method == ESHTTPMethodPost) {
        result = @"POST";
    }
    return result;
}

- (void)pretreatmentRequest:(NSString **)inoutURLString inoutParameters:(NSDictionary **)inoutParameters {
    if (![*inoutParameters isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if (![*inoutParameters count]) {
        return;
    }
    
    NSString *URLString = *inoutURLString;
    if (![URLString rangeOfString:@"{"].length || ![URLString rangeOfString:@"}"].length) {
        return;
    }
    
    /// 获取需要替换的key
    NSMutableArray<NSString *> *replaceKeys = [NSMutableArray array];
    {
        NSRange range = NSMakeRange(0, URLString.length);
        NSInteger start = -1;
        while (YES) {
            NSRange flagRange;
            if (start == -1) {
                flagRange = [URLString rangeOfString:@"{" options:NSCaseInsensitiveSearch range:range];
            }
            else {
                flagRange = [URLString rangeOfString:@"}" options:NSCaseInsensitiveSearch range:range];
            }
            if (flagRange.length <= 0) {
                break;
            }
            
            if (start == -1) {
                start = flagRange.location + flagRange.length;
            }
            else {
                [replaceKeys addObject:[URLString substringWithRange:NSMakeRange(start, flagRange.location - start)]];
                start = -1;
            }
            range.location = flagRange.location + flagRange.length;
            range.length = URLString.length - range.location;
        }
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:*inoutParameters];
    for (NSString *key in replaceKeys) {
        id value = [parameters objectForKey:key];
        if (value) {
            URLString = [URLString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:[NSString stringWithFormat:@"%@", value]];
            [parameters removeObjectForKey:key];
        }
    }
    
    *inoutURLString = URLString;
    *inoutParameters = [parameters copy];
}


@end


