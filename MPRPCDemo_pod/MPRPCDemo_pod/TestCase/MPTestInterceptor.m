//
//  MPTestInterceptor.m
//  CloudPay
//
//  Created by yangwei on 2017/9/11.
//  Copyright © 2017年 Alibaba. All rights reserved.
//

#import "MPTestInterceptor.h"

extern void MPAdapterLog(NSString *tag, NSString *componentTag, NSString *format, ...);

@interface MPTestInterceptor()

@end

static BOOL beforeRpcRun = NO;
static BOOL afterRpcRun = NO;
static BOOL handleExceptionRun = NO;

@implementation MPTestInterceptor

#pragma mark 登录态处理
- (DTRpcOperation *)beforeRpcOperation:(DTRpcOperation *)operation
{
    NSMutableURLRequest *urlRequest = (NSMutableURLRequest *)operation.request;
    NSDictionary *allHeaders = urlRequest.allHTTPHeaderFields;
    if ([operation.rpcOperationType isEqualToString:@"com.antcloud.request.postAddHeader"]) {
        assert([[allHeaders objectForKey:@"testKey"] isEqualToString:@"testValue"]);
        NSLog(@"[MPAdapter][RPC]: %@", @"添加 Header 检测通过");
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        beforeRpcRun = YES;
    });
    return operation;
}

- (DTRpcOperation *)afterRpcOperation:(DTRpcOperation *)operation
{
    NSDictionary *result = operation.responseJSON[@"result"];
    if ([result count] > 0) {
        NSHTTPURLResponse *urlReponse = (NSHTTPURLResponse *)operation.response;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afterRpcRun = YES;
    });
    return operation;
}

- (void)handleException:(NSException *)exception
{
    if ([exception isKindOfClass:[DTRpcException class]]) {
        DTRpcException *rpcException = ((DTRpcException *)exception);
        int code = rpcException.code;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            handleExceptionRun = YES;
        });
    }
}

+ (BOOL)beforeRpcOperationRun
{
    return beforeRpcRun;
}

+ (BOOL)afterRpcOperationRun
{
    return afterRpcRun;
}

+ (BOOL)handleExceptionRun
{
    return handleExceptionRun;
}

@end
