//
//  HomeSectionIndexRequest.m
//  ESNetwork
//
//  Created by 翟泉 on 2016/11/23.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "HomeSectionIndexRequest.h"

@implementation HomeSectionIndexRequest

- (NSString *)URLString {
    return @"/v2/api/page/index/MAIN";
}

- (NSTimeInterval)cacheTimeoutInterval {
    return 60 * 30;
}

@end
