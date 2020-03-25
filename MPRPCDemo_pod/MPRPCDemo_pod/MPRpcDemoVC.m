//
//  MPRpcDemoVC.m
//  MPRpcDemo
//
//  Created by shifei.wkp on 2018/11/20.
//  Copyright © 2018 alipay. All rights reserved.
//

#import "MPRpcDemoVC.h"
#import "MPRpcDemoDef.h"
#import "MPDemoRpcDemoClient.h"
#import "MPDemoGetIdGetReq.h"
#import "MPdemoPostPostReq.h"
#import "MPDemoAccountInfo.h"
#import "MPDemoUserInfo.h"
#import "MPDemoVipInfo.h"
#import "MPRpcTestCase.h"

typedef void(^MPActionBlock)(void);

@interface MPRpcDemoVC ()

@end

@implementation MPRpcDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // rpc初始化
    [MPRpcInterface initRpc];
    
    self.title = @"移动网关";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CREATE_UI({
        BUTTON_WITH_ACTION(@"调用RPC: Get", exampleRpcGet);
        BUTTON_WITH_ACTION(@"调用RPC: Post", exampleRpcPost);
//        BUTTON_WITH_ACTION(@"执行用例检测", runAllTestCase);
    })
}

- (void)runAllTestCase
{
    [MPRPCTestCase runAllTestCase];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AUNoticeDialog *alert = [[AUNoticeDialog alloc] initWithTitle:@"执行结果" message:@"RPC 用例执行完毕" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}


#pragma mark - Example rpc get
- (void)exampleRpcGet {
    __block NSString *response;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block NSDictionary *userInfo = nil;
    [DTRpcAsyncCaller callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client getIdGet:[self getRequest]];
        } @catch (DTRpcException *exception) {
            userInfo = exception.userInfo;
            NSError *error = [userInfo objectForKey:@"kDTRpcErrorCauseError"];
            NSInteger code = error.code;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
                [AUToast presentToastWithin:self.view withIcon:AUToastIconNetFailure text:errorMsg duration:1.5 logTag:@"demo" completion:nil];
                APLog(errorMsg);
            });
        }
    } completion:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (response) {
            AUNoticeDialog *alert = [[AUNoticeDialog alloc] initWithTitle:@"返回数据" message:response delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (MPDemoGetIdGetReq *)getRequest {
    MPDemoGetIdGetReq *req = [[MPDemoGetIdGetReq alloc] init];
    req.id = @"Mpaas";
    req.age = 18;
    req.isMale = YES;
    
    return req;
}


#pragma mark - Example rpc post
- (void)exampleRpcPost {
    __block MPDemoUserInfo *response;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DTRpcAsyncCaller callAsyncBlock:^{
        @try {
            MPDemoRpcDemoClient *client = [[MPDemoRpcDemoClient alloc] init];
            response = [client postPost:[self postRequest]];
        } @catch (DTRpcException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSString *errorMsg = [NSString stringWithFormat:@"Rpc Exception code : %d", exception.code];
                [AUToast presentToastWithin:self.view withIcon:AUToastIconNetFailure text:errorMsg duration:1.5 logTag:@"demo" completion:nil];
                APLog(errorMsg);
            });
        }
    } completion:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (response) {
            NSString *msg = [NSString stringWithFormat:@"Name: %@\nAge: %d\nVIP expire time: %lld\nVIP level: %d", response.name, response.age, response.vipInfo.expireTime, response.vipInfo.level];
            AUNoticeDialog *alert = [[AUNoticeDialog alloc] initWithTitle:@"返回数据" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (MPDemoPostPostReq *)postRequest {
    MPDemoPostPostReq *req = [[MPDemoPostPostReq alloc] init];
    MPDemoAccountInfo *accountInfo = [[MPDemoAccountInfo alloc] init];
    accountInfo.username = @"mpaas";
    accountInfo.password = @"123456";
    req._requestBody = accountInfo;
    
    return req;
}

@end
