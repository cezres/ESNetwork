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
- (void)requestHandleCompletionResponseObject:(id)responseObject error:(NSError *)error;

@end



@interface ESRequestHandler : NSObject


/**
 *  请求超时时间
 */
@property (assign, nonatomic) NSTimeInterval timeoutInterval;

@property (strong, nonatomic) NSString *baseURLString;


+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)handleRequest:(ESRequest *)request;

- (NSURLSessionDataTask *)handleRequestWithURLString:(NSString *)URLString Method:(ESHTTPMethod)method parameters:(id)parameters delegate:(id<ESRequestHandlerDelegate>)delegate;



@end
