//
//  ViewController.m
//  ESNetworkDemo
//
//  Created by 翟泉 on 2016/11/8.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"
#import "ESBaseRequest.h"

#import "HomeSectionIndexRequest.h"

@interface ViewController ()

@property (strong, nonatomic) ESBaseRequest *request;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [ESRequestHandler sharedInstance].baseURL = [NSURL URLWithString:@"http://test.api.d2cmall.com"];
    [[ESRequestHandler sharedInstance] setValue:@"iOS" forBuiltinParameterField:@"device"];
    
    ESBaseRequest *request = [ESBaseRequest request];
    request.URLString = @"/product/{id}";
    request.parameters = @{@"id": @1008611};
    [request startWithCompletionBlock:^(__kindof ESRequest *request) {
        
    }];
    
//    [[HomeSectionIndexRequest request] startWithCompletionBlock:^(__kindof ESRequest *request) {
//        NSLog(@"\n%@", request.responseObject);
//    }];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
