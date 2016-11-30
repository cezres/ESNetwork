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


/// 请求优先级
typedef NS_ENUM(NSInteger, ESRequestPriority) {
    ESRequestPriorityDefault,
    ESRequestPriorityLow,
    ESRequestPriorityHigh
};

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
@property (copy, nonatomic) NSObject *parameters;
@property (assign, nonatomic) ESHTTPMethod method;


/**
 请求优先级，默认ESRequestPriorityDefault
 */
@property (assign, nonatomic) ESRequestPriority priority;


/**
 内置的请求头是否有效，默认YES
 */
@property (assign, nonatomic) BOOL builtinHeaderEnable;
/**
 内置的参数舒服有效，默认YES
 */
@property (assign, nonatomic) BOOL builtinParameterEnable;


@property (assign, nonatomic) BOOL mustFromNetwork;
@property (readonly) NSURLSessionTaskState state;
@property (assign, nonatomic) NSInteger tag;
@property (strong, nonatomic, readonly) NSURLSessionTask *task;


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
/**
 数据从缓存中读取
 */
@property (assign, nonatomic, readonly, getter=isDataFromCache) BOOL dataFromCache;


#pragma mark Response
@property (strong, nonatomic, readonly) NSHTTPURLResponse *response;
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

- (__kindof ESRequest *)stop;


- (void)willStart __attribute__((objc_requires_super));

- (void)completed __attribute__((objc_requires_super));



@end
