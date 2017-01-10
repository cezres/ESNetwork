//
//  ESBaseRequest.h
//  ESNetwork
//
//  Created by 翟泉 on 2016/11/8.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequest.h"
#import <UIKit/UIKit.h>

@class ESBaseRequest;

typedef void (^ESBaseRequestBlock)(__kindof ESBaseRequest *request);

@interface ESBaseRequest : ESRequest

@property (assign, nonatomic, readonly) NSInteger responseStatusCode;

@property (strong, nonatomic, readonly) NSDictionary *responseData;

@property (strong, nonatomic, readonly) NSString *errorMsg;


- (ESBaseRequest *)startWithCompletionBlock:(ESBaseRequestBlock)completionBlock;


#pragma mark - Loading提示

/**
 *  Loading提示视图的父视图
 *  如果不为NULL，就显示Loading提示
 */
@property (weak, nonatomic, readonly) UIView *loadingInView;



/**
 *  初始化数据请求对象
 *
 *  @param loadingInView Loading提示视图的父视图
 */
+ (instancetype)requestWithLoadingInView:(UIView *)loadingInView;


#pragma mark - 数据分页的请求

/**
 *  分页数据的KeyPath
 */
@property (strong, nonatomic) NSString *pageKeyPath;

/**
 *  分页数据
 */
@property (strong, nonatomic, readonly) NSDictionary *pageDict;

/**
 *  当前数据页码
 */
@property (assign, nonatomic, readonly) NSInteger index;

/**
 *  是否存在下一页数据
 */
@property (assign, nonatomic, readonly) BOOL hasNext;

/**
 *  设置下一页分页参数
 */
- (BOOL)nextPage;


@end
