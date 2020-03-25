//
//  DTRpcCommonInterceptor.m
//  CloudPay
//
//  Created by yangwei on 2017/9/11.
//  Copyright © 2017年 Alibaba. All rights reserved.
//

#import "DTRpcCommonInterceptor.h"
#import "MPTestInterceptor.h"

@interface DTRpcCommonInterceptor ()

@property(nonatomic, strong) NSMutableArray *interceptorArray;

@end

@implementation DTRpcCommonInterceptor

- (id)init
{
    self = [super init];
    if (self)
    {
        NSMutableArray *interceptorList = [[NSMutableArray alloc]init];
        // 注册需要的拦截器
        MPTestInterceptor *mpTestIntercaptor = [[MPTestInterceptor alloc] init];
        [interceptorList addObject:mpTestIntercaptor];
        
        self.interceptorArray = interceptorList;
    }
    return self;
}

//rpc发送前执行
- (DTRpcOperation *)beforeRpcOperation:(DTRpcOperation *)operation
{
    DTRpcOperation *newOperation = operation;

    if (self.interceptorArray && [self.interceptorArray count] > 0) {
        NSArray *tmpArray = [self.interceptorArray copy];
        for (id<DTRpcInterceptor> interceptor in tmpArray) {
            if ([interceptor respondsToSelector:@selector(beforeRpcOperation:)]) {
                newOperation = [interceptor beforeRpcOperation:newOperation];
            }
        }
    }
    
    return newOperation;
}

//rpc结果返回给业务方前执行
- (DTRpcOperation *)afterRpcOperation:(DTRpcOperation *)operation
{
    DTRpcOperation *newOperation = operation;
    if (self.interceptorArray && [self.interceptorArray count] > 0) {
        NSArray *tmpArray = [self.interceptorArray copy];
        for (id<DTRpcInterceptor> interceptor in tmpArray) {
            if ([interceptor respondsToSelector:@selector(afterRpcOperation:)]) {
                newOperation = [interceptor afterRpcOperation:newOperation];
            }
        }
    }
    return newOperation;
}

//rpc异常需要处理时执行
- (BOOL)needRaiseException:(NSException *)exception
{
    [self handleException:exception];
    return YES;
}

- (void)handleException:(NSException *)exception
{
    if (self.interceptorArray && [self.interceptorArray count] > 0) {
        NSArray *tmpArray = [self.interceptorArray copy];
        for (id<DTRpcInterceptor> interceptor in tmpArray) {
            if ([interceptor respondsToSelector:@selector(handleException:)]) {
                [interceptor handleException:exception];
            }
        }
    }
}

//添加rpc拦截器
- (void)addRpcInterceptor:(id<DTRpcInterceptor>)RPCInterceptor
{
    if (RPCInterceptor == nil) {
        return;
    }
    if (self.interceptorArray == nil) {
        self.interceptorArray = [[NSMutableArray alloc]init];
    }
    if ([self.interceptorArray indexOfObject:RPCInterceptor] == NSNotFound) {
        [self.interceptorArray addObject:RPCInterceptor];
    }
}

//移除rpc拦截器
- (void)removeRpcInterceptor:(id<DTRpcInterceptor>)RPCInterceptor
{
    if (RPCInterceptor == nil || self.interceptorArray == nil || [self.interceptorArray count] == 0) {
        return;
    }
    [self.interceptorArray removeObject:RPCInterceptor];
}

#pragma mark - Utils
-(NSArray*)interceptorList
{
    NSArray *arr = [[NSArray alloc] initWithArray:self.interceptorArray];
    return arr;
}

@end
