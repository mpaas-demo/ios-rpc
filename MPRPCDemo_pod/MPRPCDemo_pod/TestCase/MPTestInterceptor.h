//
//  MPTestInterceptor.h
//  CloudPay
//
//  Created by yangwei on 2017/9/11.
//  Copyright © 2017年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPTestInterceptor : NSObject<DTRpcInterceptor>

+ (BOOL)beforeRpcOperationRun;

+ (BOOL)afterRpcOperationRun;

+ (BOOL)handleExceptionRun;

@end
