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

RCT_EXPORT_METHOD(initClient:(NSString *)key callback:(RCTResponseSenderBlock)callback) {
    JVAuthConfig *cf = [[JVAuthConfig alloc] init];
    cf.authBlock = ^(NSDictionary *result) {
        callback(@[result]);
    };
    cf.appKey = key;
    [JVERIFICATIONService setupWithConfig:cf];
}


RCT_EXPORT_METHOD(setDebug: (nonnull NSNumber *)enable) {
    [JVERIFICATIONService setDebug: [enable boolValue]];
}

RCT_EXPORT_METHOD(checkVerifyEnable: (RCTResponseSenderBlock)callback){
    if([JVERIFICATIONService checkVerifyEnable]) {
        callback(@[@YES]);
    }else{
        callback(@[@NO]);
    }
}

RCT_EXPORT_METHOD(preLogin: (NSDictionary *)params callback: (RCTResponseSenderBlock)callback) {
    //预取号
    if (![JVERIFICATIONService isSetupClient]) {
        callback(@[@NO]);
        return;
    }
    [JVERIFICATIONService preLogin:[[params objectForKey:@"timeout"] longValue]  completion:^(NSDictionary *result) {
        callback(@[result]);
    }];
}

RCT_EXPORT_METHOD(clearPreloginCache) {
    [JVERIFICATIONService clearPreLoginCache];
}


RCT_EXPORT_METHOD(loginAuth: (NSDictionary *)params callback: (RCTResponseSenderBlock)callback) {
    __block BOOL isCallBacked = NO;
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
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
        }
        [JVERIFICATIONService dismissLoginController];
    }];
    
    [JVERIFICATIONService getAuthorizationWithController:rootViewController hide:YES completion:^(NSDictionary *result) {
        if (isCallBacked == NO) {
            callback(@[result]);
        }
    }];
    
    
    
}

- (void)customUI:(RCTResponseSenderBlock)callback  params:(NSDictionary *)params block:(resultCallBlcok)block {
    
    JVUIConfig *config = [[JVUIConfig alloc] init];
    config.navReturnHidden = NO;
    config.logoImg = [UIImage imageNamed:@"native_login_icon"];
    config.logoWidth=112;
    config.logoHeight=42;
    config.logBtnText=@"一键登入";
    config.navText = [[NSAttributedString alloc] initWithString:@""];
    config.navColor= [UIColor whiteColor];
    config.barStyle = 1;
    config.navReturnImg = [UIImage imageNamed:@"close"];
    config.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    config.sloganOffsetY=230;
    config.privacyState=YES;
    config.checkViewHidden=YES;
    config.agreementNavReturnImage = [UIImage imageNamed:@"back"];
    config.agreementNavBackgroundColor=[UIColor whiteColor];
    config.agreementNavTextColor=[UIColor colorWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1.0];
    
    CGFloat spacing =  20 + 5 + 5;
    JVLayoutConstraint *privacyConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeLeft multiplier:1 constant:spacing];
     JVLayoutConstraint *privacyConstraintX2 = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeRight multiplier:1 constant:-spacing];
     JVLayoutConstraint *privacyConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeBottom multiplier:1 constant:-10];
     JVLayoutConstraint *privacyConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:50];
     config.privacyConstraints = @[privacyConstraintX,privacyConstraintX2,privacyConstraintY,privacyConstraintH];
     config.privacyHorizontalConstraints = config.privacyConstraints;

    
    [JVERIFICATIONService customUIWithConfig:config customViews:^(UIView *customAreaView) {
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
