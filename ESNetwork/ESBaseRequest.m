//
//  ESBaseRequest.m
//  ESNetwork
//
//  Created by 翟泉 on 2016/11/8.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESBaseRequest.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ESBaseRequest ()

@property (weak, nonatomic) UIView *loadingInView;

@property (strong, nonatomic) MBProgressHUD *loadingView;

@end


@implementation ESBaseRequest


+ (instancetype)requestWithLoadingInView:(UIView *)loadingInView {
    ESBaseRequest *request = [super request];
    request.loadingInView = loadingInView;
    return request;
}

- (MBProgressHUD *)loadingView {
    if (_loadingInView && !_loadingView) {
        _loadingView = [[MBProgressHUD alloc] initWithView:_loadingInView];
        _loadingView.removeFromSuperViewOnHide = YES;
        [_loadingInView addSubview:_loadingView];
    }
    return _loadingView;
}

- (void)willStart {
    [_loadingView showAnimated:YES];
}

- (void)completed {
    [super completed];
    [_loadingView hideAnimated:YES];
    _loadingView = NULL;
}

- (ESBaseRequest *)startNextPageWithDelegate:(id<ESRequestDelegate>)delegate {
    self.delegate = delegate;
    return [self startNextPage];
}

- (ESBaseRequest *)startNextPageWithCompletionBlock:(ESRequestBlock)completionBlock {
    self.completionBlock = completionBlock;
    return [self startNextPage];
}

- (ESBaseRequest *)startNextPage {
    if (!self.hasNext) {
        return self;
    }
    if (![self.parameters isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)self.parameters];
    [mutableDict setObject:@(self.index + 1) forKey:@"p"];
    self.parameters = mutableDict;
    [self start];
    return self;
}

- (NSInteger)index {
    if (!self.responseObject) {
        return -1;
    }
    else if (![self.responseObject isKindOfClass:[NSDictionary class]]) {
        return -1;
    }
    else if ([self.pageKeyPath length] == 0) {
        return -1;
    }
    NSNumber *index = [[self.responseObject valueForKeyPath:self.pageKeyPath] objectForKey:@"index"];
    if (!index) {
        return -1;
    }
    return [index integerValue];
}

- (BOOL)hasNext {
    if (!self.responseObject) {
        return NO;
    }
    else if (![self.responseObject isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    else if ([self.pageKeyPath length] == 0) {
        return NO;
    }
    NSNumber *next = [[self.responseObject valueForKeyPath:self.pageKeyPath] objectForKey:@"next"];
    if (!next) {
        return NO;
    }
    return [next boolValue];
}

- (NSString *)pageKeyPath {
    if (!_pageKeyPath) {
        NSMutableString *keyPath = [NSMutableString string];
        BOOL result = [self analysisKeyPath:@"next" forDict:self.responseObject keyPath:keyPath];
        if (result) {
            _pageKeyPath = [keyPath substringFromIndex:1];
        }
        else {
            _pageKeyPath = @"";
        }
    }
    return _pageKeyPath;
}

- (BOOL)analysisKeyPath:(NSString *)flag forDict:(NSDictionary *)dict keyPath:(NSMutableString *)keyPath {
    for (NSString *key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        if ([key isEqualToString:flag]) {
            return YES;
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            [keyPath appendFormat:@".%@", key];
            BOOL result = [self analysisKeyPath:flag forDict:value keyPath:keyPath];
            if (result) {
                return  result;
            }
        }
    }
    keyPath = [NSMutableString string];
    return NO;
}




@end
