//
//  ESRequest.h
//  ESNetwork
//
//  Created by 翟泉 on 2016/11/8.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESRequestCache.h"
#import "ESRequestHandler.h"

@class ESRequest;

typedef void (^ESRequestBlock)(__kindof ESRequest *request);

@protocol ESRequestDelegate <NSObject>

/**
 *  请求完成后回调
 *
 *  @param request <#request description#>
 */
- (void)requestCompletion:(__kindof ESRequest *)request;

@end

@interface ESRequest : NSObject
<ESRequestHandlerDelegate>

@property (copy, nonatomic) NSString *URLString;
@property (assign, nonatomic) ESHTTPMethod method;
@property (copy, nonatomic) NSObject *parameters;


@property (assign, nonatomic) BOOL mustFromNetwork;
@property (readonly) NSURLSessionTaskState state;
@property (assign, nonatomic) NSInteger tag;
@property (strong, nonatomic) NSURLSessionTask *task;


#pragma mark Cache

/**
 *  缓存时间，0不缓存
 */
@property (assign, nonatomic) NSTimeInterval cacheTimeoutInterval;
/**
 *  缓存-组名称 默认MD5(URLString)
 */
@property (copy, nonatomic, readonly) NSString *groupName;
/**
 *  缓存-标识  MD5(URLString+parameters)
 */
@property (copy, nonatomic, readonly) NSString *identifier;


#pragma mark Response

@property (strong, nonatomic, readonly) id responseObject;

@property (strong, nonatomic, readonly) NSError *error;


#pragma mark Callback

@property (weak, nonatomic) id<ESRequestDelegate> delegate;
/**
 *  请求完成后会释放
 */
@property (copy, nonatomic) ESRequestBlock completionBlock;



+ (instancetype)request;


- (__kindof ESRequest *)startWithDelegate:(id<ESRequestDelegate>)delegate;

- (__kindof ESRequest *)startWithCompletionBlock:(ESRequestBlock)completionBlock;

- (__kindof ESRequest *)start;

- (__kindof ESRequest *)pause;

- (__kindof ESRequest *)stop;


- (void)willStart;

- (void)completed __attribute__((objc_requires_super));



@end
