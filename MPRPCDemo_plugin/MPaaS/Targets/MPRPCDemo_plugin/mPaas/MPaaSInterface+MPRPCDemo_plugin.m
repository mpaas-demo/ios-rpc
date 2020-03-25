//
//  MPaaSInterface+MPRPCDemo_plugin.m
//  MPRPCDemo_plugin
//
//  Created by yemingyu on 2020/03/25.
//  Copyright © 2020 Alibaba. All rights reserved.
//

#import "MPaaSInterface+MPRPCDemo_plugin.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation MPaaSInterface (MPRPCDemo_plugin)

- (BOOL)enableSettingService
{
    return NO;
}

- (NSString *)userId
{
    return nil;
}

@end

#pragma clang diagnostic pop
