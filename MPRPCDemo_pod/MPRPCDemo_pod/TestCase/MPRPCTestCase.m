//
//  MPRPCTestCase.m
//  MPRpcDemo
//
//  Created by yemingyu on 2019/2/13.
//  Copyright © 2019 alipay. All rights reserved.
//

#import "MPRPCTestCase.h"
#import "MPDemoRpcDemoClient.h"
#import "MPDemoGetIdGetReq.h"
#import "MPdemoPostPostReq.h"
#import "MPDemoAccountInfo.h"
#import "MPDemoUserInfo.h"
#import "MPDemoVipInfo.h"
#import <APMobileNetwork/DTRpcInterface.h>
#import "MPTestInterceptor.h"
#import <MPBaseTest/MPBaseUtil.h>

typedef void(^MPActionBlock)(void);

@interface MPRPCTestCase ()
{
    
}
@end

static NSString *_rpcGW;

@implementation MPRPCTestCase

+ (void)runAllTestCase
{
    MPTestInterceptor *mpTestIntercaptor = [[MPTestInterceptor alloc] init];
    if ([[DTRpcClient defaultClient].interceptor isKindOfClass:NSClassFromString(@"MPRpcCommonInterceptor")]) {
        [MPRpcInterface addRpcInterceptor:mpTestIntercaptor];
    }
    
    BOOL isEncrypted = NO;
    isEncrypted = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"mPaaSCrypt"] boolForKey:@"Crypt"];
    [self testIsAMRpc];
    // TODO: meta.config 加到工程中才行
    [self testUrlAddressConfig];
    [self testmPaaSCrypt];
    
//    if (YES == isEncrypted) {
        [self testRpcGet];
        [self testRpcPost];
        [self testRpcPostPb];
        [self testRpcPostNotExist];
        [self testRpcPostLimit];
//    } else {
        [self testRpcPostDecryptFailed];
//    }
    [self testRpcPostSetTimeOut];
    [self testRpcPostAddHeader];
    
    [self testRpcInterceptor];
}

+ (void)testIsAMRpc
{
    DTRpcConfig *config = [[DTRpcClient defaultClient] configForScope:kDTRpcConfigScopeGlobal];
    assert(config.isAMRPC == YES);
    MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"V2 配置 检测通过");
}

+ (void)testUrlAddressConfig
{
    // TODO: 读取 meta.config 然后和接口读出来的做对比
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"config"];
    NSString *metaConfig = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSDictionary *metaConfig = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
    NSData *jsonData = [metaConfig dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    _rpcGW = [dic objectForKey:@"rpcGW"];
    NSString *appId = [dic objectForKey:@"appId"];
    NSString *appKey = [dic objectForKey:@"appKey"];
    NSString *workspaceId = [dic objectForKey:@"workspaceId"];
    
    NSString *gatewayURL = [[DTRpcInterface sharedInstance] gatewayURL];
    
    NSString *productId = [[DTRpcInterface sharedInstance] productId];
    
    NSString *signKeyForRequest = [[DTRpcInterface sharedInstance] signKeyForRequest:[NSURLRequest new]];
    
    NSString *rpc_WorkspaceId = [[DTRpcInterface sharedInstance] WorkspaceId];
    
    NSString *commonInterceptorClassName = [[DTRpcInterface sharedInstance] commonInterceptorClassName];
    
//    NSString *appKey_workspaceId = [NSString stringWithFormat:@"%@-%@", appKey, workspaceId];
    
//    NSString *InfoProductID = [[DTRpcInterface sharedInstance] productId];
    
    
    assert([_rpcGW isEqualToString:gatewayURL]);
    MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"网关地址 检测通过");
    assert([productId isEqualToString:appId]);
    MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"productId 检测通过");
    assert([signKeyForRequest isEqualToString:appKey]);
    MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"signKeyForRequest 检测通过");
    
    assert([rpc_WorkspaceId isEqualToString:workspaceId]);
    MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"workspaceId 检测通过");
    
    assert([commonInterceptorClassName isEqualToString:@"MPRpcCommonInterceptor"]);
    MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"全局拦截器 检测通过");
    
//    - (NSString*)commonInterceptorClassName
//    {
//        return @"DTRpcCommonInterceptor";
//    }
    // 检测无线保镖图片是否存在
    UIImage *yw_1222 = [UIImage imageNamed:@"yw_1222.jpg"];
    assert(nil != yw_1222);
    MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"无线保镖存在 检测通过");
}

+ (void)testmPaaSCrypt
{
    NSDictionary *dic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"mPaaSCrypt"];
    if (nil == dic) {
        MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"客户端没有配置加密，注意服务端数据加密开关是否关闭");
    } else {
        // 检测是否开启
        BOOL isEncrypted = [[dic objectForKey:@"Crypt"] boolValue];
        if (YES == isEncrypted) {
            MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"客户端已配置加密，注意服务端数据加密开关是否开启，如果不开启则可能 7002，客户端服务端类型要匹配，否则可能出现 5000");
        } else {
            MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"客户端配置加密 mPaaSCrypt，但开关 Crypt 没有开启");
        }
        // 检测每一项是否存在
        NSString *PubKey = [dic objectForKey:@"PubKey"];
        if (PubKey) {
            MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"客户端加密配置 公钥已配置");
        } else {
            assert(nil != PubKey);
        }
        NSString *SecretKey = [dic objectForKey:@"RSA/ECC/SM2"];
        if (SecretKey) {
            MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"客户端加密配置 私钥已配置");
        } else {
            assert(nil != SecretKey);
        }
        NSArray *GWWhiteList = [dic objectForKey:@"GWWhiteList"];
        if (GWWhiteList) {
            BOOL isContainMGW = [GWWhiteList containsObject:_rpcGW];
            assert(YES == isContainMGW);
            MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"客户端加密配置 白名单已配置网关地址");
        } else {
            assert(nil != GWWhiteList);
        }
    }
}

#pragma mark - Example rpc get
+ (void)testRpcGet {
    __block MPDemoUserInfo *response;
    [MPRpcInterface callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client getIdGet:[self getRequest]];
        } @catch (DTRpcException *exception) {
            NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
            assert(999 == exception.code);
        }
    } completion:^{
        NSString *msg = nil;
        if (response) {
            msg = [NSString stringWithFormat:@"Name: %@ Age: %d VIP expire time: %lld VIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
            
        }
        BOOL result = NO;
        result = [msg isEqualToString:@"Name: alipay TestCase Age: 20 VIP expire time: 1532599846111 VIP level: 101"];
        assert(result == YES);
        MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"Get 检测通过");
    }];
}

+ (MPDemoGetIdGetReq *)getRequest {
    MPDemoGetIdGetReq *req = [[MPDemoGetIdGetReq alloc] init];
    req.id = @"Mpaas";
    req.age = 18;
    req.isMale = YES;
    
    return req;
}


#pragma mark - Example rpc post
+ (void)testRpcPost {
    __block MPDemoUserInfo *response;
    [MPRpcInterface callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client postPost:[self postRequest]];
        } @catch (DTRpcException *exception) {
            NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
            assert(999 == exception.code);
        }
    } completion:^{
        NSString *msg = nil;
        if (response) {
            msg = [NSString stringWithFormat:@"Name: %@ Age: %d VIP expire time: %lld VIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
            
        }
        BOOL result = NO;
        result = [msg isEqualToString:@"Name: alipay TestCase Age: 20 VIP expire time: 1532599846111 VIP level: 101"];
        assert(result == YES);
        MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"Post 检测通过");
    }];
}

+ (MPDemoPostPostReq *)postRequest {
    MPDemoPostPostReq *req = [[MPDemoPostPostReq alloc] init];
    MPDemoAccountInfo *accountInfo = [[MPDemoAccountInfo alloc] init];
    accountInfo.username = @"mpaas";
    accountInfo.password = @"123456";
    req._requestBody = accountInfo;

    return req;
}

#pragma mark - Example rpc postPb
+ (void)testRpcPostPb {
    __block MPDemoUserInfo *response;
    [MPRpcInterface callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client dataPostPb:[self postRequest]];
        } @catch (DTRpcException *exception) {
            NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
            assert(999 == exception.code);
        }
    } completion:^{
        NSString *msg = nil;
        if (response) {
            msg = [NSString stringWithFormat:@"Name: %@ Age: %d VIP expire time: %lld VIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
            
        }
        BOOL result = NO;
        result = [msg isEqualToString:@"Name: alipay TestCase Age: 20 VIP expire time: 1532599846111 VIP level: 102"];
        assert(result == YES);
        MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"PostPb 检测通过");
    }];
}

#pragma mark - Example rpc postLimit
+ (void)testRpcPostLimit {
    __block MPDemoUserInfo *response;
    [MPRpcInterface callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client dataPostLimit:[self postRequest]];
        } @catch (DTRpcException *exception) {
            NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
            assert(999 == exception.code);
        }
    } completion:^{
        NSString *msg = nil;
        if (response) {
            msg = [NSString stringWithFormat:@"Name: %@ Age: %d VIP expire time: %lld VIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
            
        }
        BOOL result = NO;
        result = [msg isEqualToString:@"Name: Limit TestCase Age: 20 VIP expire time: 1532599846111 VIP level: 102"];
        assert(result == YES);
        MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"Post 限流 检测通过");
    }];
}

#pragma mark - Example rpc postNotExist
+ (void)testRpcPostNotExist {
    __block MPDemoUserInfo *response;
    [MPRpcInterface callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client dataPostNotExist:[self postRequest]];
        } @catch (DTRpcException *exception) {
            NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
            assert(3000 == exception.code);
            MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"Post 接口不存在 检测通过");
        }
    } completion:^{
        NSString *msg = nil;
        assert(nil == response);
        if (response) {
            msg = [NSString stringWithFormat:@"Name: %@ Age: %d VIP expire time: %lld VIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
            BOOL result = NO;
            result = [msg isEqualToString:@"Name: alipay TestCase Age: 20 VIP expire time: 1532599846111 VIP level: 102"];
            assert(result == YES);
        }
    }];
}

#pragma mark - Example rpc postDecryptFailed
// 客户端没有开启加密，服务端开启了解密，反之则直接7002，因为服务端找签名找不到
+ (void)testRpcPostDecryptFailed {
    __block MPDemoUserInfo *response;
    [MPRpcInterface callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client dataPostDecryptFailed:[self postRequest]];
        } @catch (DTRpcException *exception) {
            NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
            assert(3003 == exception.code);
            MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"Post 解密失败 检测通过");
        }
    } completion:^{
        NSString *msg = nil;
        if (response) {
            msg = [NSString stringWithFormat:@"Name: %@ Age: %d VIP expire time: %lld VIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
            BOOL result = NO;
            result = [msg isEqualToString:@"Name: alipay TestCase Age: 20 VIP expire time: 1532599846111 VIP level: 101"];
            assert(result == YES);
        }
        assert(nil == response);
        
    }];
}

#pragma mark - Example rpc post timeout

+ (void)testRpcPostSetTimeOut {
    __block MPDemoUserInfo *response;
    [MPRpcInterface callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client dataPostSetTimeout:[self postRequest]];
        } @catch (DTRpcException *exception) {
//            NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
//            assert(3003 == exception.code);
//            MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"Post 解密失败 检测通过");
        }
    } completion:^{
//        NSString *msg = nil;
//        if (response) {
//            msg = [NSString stringWithFormat:@"Name: %@ Age: %d VIP expire time: %lld VIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
//            BOOL result = NO;
//            result = [msg isEqualToString:@"Name: alipay TestCase Age: 20 VIP expire time: 1532599846111 VIP level: 101"];
//            assert(result == YES);
//        }
//        assert(nil == response);
    }];
}

#pragma mark - Example rpc post AddHeader

+ (void)testRpcPostAddHeader {
    __block MPDemoUserInfo *response;
    [MPRpcInterface callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client dataPostAddHeader:[self postRequest]];
        } @catch (DTRpcException *exception) {
            NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
            assert(3000 == exception.code);
        }
    } completion:^{
        NSString *msg = nil;
        if (response) {
            msg = [NSString stringWithFormat:@"Name: %@ Age: %d VIP expire time: %lld VIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
            BOOL result = NO;
            result = [msg isEqualToString:@"Name: alipay TestCase Age: 20 VIP expire time: 1532599846111 VIP level: 101"];
            assert(result == YES);
        }
        assert(nil == response);
    }];
}

#pragma mark - 拦截器

+ (void)testRpcInterceptor
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL beforeRpc = [MPTestInterceptor beforeRpcOperationRun];
        BOOL afterRpc = [MPTestInterceptor afterRpcOperationRun];
        BOOL handleException = [MPTestInterceptor handleExceptionRun];
        assert(beforeRpc);
        assert(afterRpc);
        assert(handleException);
        MPAdapterLog(@"MPAdapter", @"RPC", @"%@", @"拦截器 检测通过");
    });
}

@end
