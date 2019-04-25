//
//  RCTJVerificationModule.m
//  RCTJVerificationModule
//
//  Created by oshumini on 2018/11/5.
//  Copyright © 2018 HXHG. All rights reserved.
//

#import "RCTJVerificationModule.h"

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTEventDispatcher.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTEventDispatcher.h"
#import "RCTRootView.h"
#import "RCTBridge.h"
#elif __has_include("React/RCTBridge.h")
#import "React/RCTEventDispatcher.h"
#import "React/RCTRootView.h"
#import "React/RCTBridge.h"
#endif

#import "CustomButton.h"
#import "JVERIFICATIONService.h"


#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

typedef enum ButtonType {
    LeftButton = 0,
    RightButton = 1
} ButtonType;
typedef void(^resultCallBlcok) (ButtonType buttonType);

@implementation RCTJVerificationModule

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getToken: (RCTResponseSenderBlock)callback) {
    
    [JVERIFICATIONService getToken:^(NSDictionary *result) {
        callback(@[result]);
    }];
}

RCT_EXPORT_METHOD(verifyNumber: (NSDictionary *)params
                  callback: (RCTResponseSenderBlock)callback) {
    JVAuthEntity *entity = [[JVAuthEntity alloc] init];
    
    if (params[@"number"]) {
        entity.number = params[@"number"];
    }
    
    if (params[@"token"]) {
        entity.token = params[@"token"];
    }
    
    [JVERIFICATIONService verifyNumber:entity result:^(NSDictionary *result) {
        callback(@[result]);
    }];
}

RCT_EXPORT_METHOD(setDebug: (nonnull NSNumber *)enable) {
    [JVERIFICATIONService setDebug: [enable boolValue]];
}

RCT_EXPORT_METHOD(loginAuth: (NSDictionary *)params callback: (RCTResponseSenderBlock)callback) {
    __block BOOL isCallBacked = NO;
    UIViewController *rootVC = UIApplication.sharedApplication.delegate.window.rootViewController;
    while (rootVC.presentedViewController != nil) {
        rootVC = rootVC.presentedViewController;
    }
    [self customUI:callback params:params block:^(ButtonType buttonType) {
        
        if (isCallBacked == NO) {
            isCallBacked = YES;
            
            NSString * type = [NSString stringWithFormat:@"%d",buttonType];
            if([type isEqual:@"0"]){
                //验证码登入
                NSDictionary *dic=@{@"code":@(8000),@"content":@""};
                callback(@[dic]);
            }else{
                //微信登入
                NSDictionary *dic=@{@"code":@(9000),@"content":@""};
                callback(@[dic]);
            }
            
            [rootVC dismissViewControllerAnimated:NO completion:nil];
        }
    }];
    
    [JVERIFICATIONService getAuthorizationWithController:rootVC completion:^(NSDictionary *result) {
        if (isCallBacked == NO) {
            callback(@[result]);
        }
    }];
    
    
    
}

- (void)customUI:(RCTResponseSenderBlock)callback  params:(NSDictionary *)params block:(resultCallBlcok)block {
    /*移动*/
    JVMobileUIConfig *mobileUIConfig = [[JVMobileUIConfig alloc] init];
    mobileUIConfig.logoImg = [UIImage imageNamed:@"native_login_icon"];
    mobileUIConfig.checkedImg=[UIImage imageNamed:@"checkBox_selected"];
    mobileUIConfig.uncheckedImg=[UIImage imageNamed:@"checkBox_unSelected"];
    mobileUIConfig.logoWidth=112;
    mobileUIConfig.logoHeight=42;
    mobileUIConfig.logBtnText=@"一键登入";
    mobileUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    mobileUIConfig.navColor= [UIColor whiteColor];
    mobileUIConfig.barStyle = 1;
    mobileUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    mobileUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    mobileUIConfig.sloganOffsetY=230;
    
    [JVERIFICATIONService customUIWithConfig:mobileUIConfig customViews:^(UIView *customAreaView) {
        [self getLoginTypesView:customAreaView andParams:params andBlock:block];
    }];
    
    /*联通*/
    JVUnicomUIConfig *unicomUIConfig = [[JVUnicomUIConfig alloc] init];
    unicomUIConfig.logoImg = [UIImage imageNamed:@"native_login_icon"];
    unicomUIConfig.checkedImg=[UIImage imageNamed:@"checkBox_selected"];
    unicomUIConfig.uncheckedImg=[UIImage imageNamed:@"checkBox_unSelected"];
    unicomUIConfig.logoWidth=112;
    unicomUIConfig.logoHeight=42;
    unicomUIConfig.logBtnText=@"一键登入";
    unicomUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    unicomUIConfig.navColor= [UIColor whiteColor];
    unicomUIConfig.barStyle = 1;
    unicomUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    unicomUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    unicomUIConfig.sloganOffsetY=230;
    
    [JVERIFICATIONService customUIWithConfig:unicomUIConfig customViews:^(UIView *customAreaView) {
        [self getLoginTypesView:customAreaView andParams:params andBlock:block];
    }];
    
    /*电信*/
    JVTelecomUIConfig *telecomUIConfig = [[JVTelecomUIConfig alloc] init];
    telecomUIConfig.checkedImg=[UIImage imageNamed:@"checkBox_selected"];
    telecomUIConfig.uncheckedImg=[UIImage imageNamed:@"checkBox_unSelected"];
    telecomUIConfig.logoImg = [UIImage imageNamed:@"native_login_icon"];
    telecomUIConfig.logoWidth=112;
    telecomUIConfig.logBtnText=@"一键登入";
    telecomUIConfig.logoHeight=42;
    telecomUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    telecomUIConfig.navColor= [UIColor whiteColor];
    telecomUIConfig.barStyle = 1;
    telecomUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    telecomUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    telecomUIConfig.sloganOffsetY=230;
    
    [JVERIFICATIONService customUIWithConfig:telecomUIConfig customViews:^(UIView *customAreaView) {
        [self getLoginTypesView:customAreaView andParams:params andBlock:block];
    }];
    
    
}

- (void)getLoginTypesView:(UIView *)customAreaView andParams:(NSDictionary *)params andBlock:(resultCallBlcok)block {
    CGFloat viewOffY = SCREEN_HEIGHT - 260;
    if (@available(iOS 11.0, *)) {
        viewOffY = SCREEN_HEIGHT - 280 - [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    int viewWidth = SCREEN_WIDTH - 50;
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, viewOffY, viewWidth, 140)];
    
    UIView * leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH-50)/3.2, 0.8)];
    leftLine.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(243/255.0 ) blue:(243/255.0 ) alpha:(1/1.0)];
    [view addSubview:leftLine];
    
    UIView * rightLine = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-50)-(SCREEN_WIDTH-50)/3.2, 0, (SCREEN_WIDTH-50)/3.2, 0.8)];
    rightLine.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(243/255.0 ) blue:(243/255.0 ) alpha:(1/1.0)];
    [view addSubview:rightLine];
    
    UILabel *childLabel = [[UILabel alloc] init];
    childLabel.text = @"其他登入方式";
    childLabel.font=[childLabel.font fontWithSize:14];
    childLabel.textColor = [UIColor colorWithRed:(152/255.0) green:(152/255.0 ) blue:(152/255.0 ) alpha:(1/1.0)];
    [childLabel sizeToFit];
    childLabel.center = CGPointMake(CGRectGetMidX(view.bounds), 0);
    [view addSubview:childLabel];
    
    CGRect rect;
    float x = (viewWidth - 110 - 50) / 2;
    if([[params objectForKey:@"isInstallWechat"] boolValue] == YES) {
        rect = CGRectMake(x, 40, 60, 60);
    }else{
        rect = CGRectMake(viewWidth/2-30, 40, 60, 60);
    }
    
    CustomButton *lButton = [CustomButton initButtonWithFrame:rect  backgroundImage:[UIImage imageNamed:@"native_phone_number_login"] block:^{
        if (block) {
            block(LeftButton);
        }
    }];
    [view addSubview:lButton];
    
    if([[params objectForKey:@"isInstallWechat"] boolValue] == YES) {
        CustomButton *rButton = [CustomButton initButtonWithFrame:CGRectMake(x+110, 40, 50, 60) backgroundImage:[UIImage imageNamed:@"native_wechat_login"] block:^{
            if (block) {
                block(RightButton);
            }
        }];
        [view addSubview:rButton];
    }
    
    view.center = CGPointMake(CGRectGetMidX(customAreaView.bounds), view.center.y);
    [customAreaView addSubview:view];
}

@end
