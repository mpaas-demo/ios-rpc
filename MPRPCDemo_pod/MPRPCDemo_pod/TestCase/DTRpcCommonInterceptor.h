//
//  DTRpcCommonInterceptor.h
//  CloudPay
//
//  Created by yangwei on 2017/9/11.
//  Copyright © 2017年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 拦截器只能有一个，但是可以衍生出无限个，参考 init 中添加其他拦截器，以及各个回调函数的调用
 */
@interface DTRpcCommonInterceptor : NSObject <DTRpcInterceptor>

/**
 * 添加RPC拦截器。
 *
 * @param RPCInterceptor 要添加的RPC拦截器对象。
 */
- (void)addRpcInterceptor:(id<DTRpcInterceptor>)RPCInterceptor;

/**
 * 从现有的拦截器列表中移除RPC拦截器。
 *
 * @param RPCInterceptor 要移除的RPC拦截器对象。
 */
- (void)removeRpcInterceptor:(id<DTRpcInterceptor>)RPCInterceptor;

/**
 * 返回当前DTRpcCommonInterceptor对象的拦截器列表。
 *
 * @return 拦截器列表数组。
 */
-(NSArray*)interceptorList;

@end
