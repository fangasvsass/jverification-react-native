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

RCT_EXPORT_METHOD(loginAuth: (RCTResponseSenderBlock)callback) {
    __block BOOL isCallBacked = NO;
    UIViewController *rootVC = UIApplication.sharedApplication.delegate.window.rootViewController;
    while (rootVC.presentedViewController != nil) {
        rootVC = rootVC.presentedViewController;
    }
    [self customUI:callback block:^(ButtonType buttonType) {
        
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

- (void)customUI:(RCTResponseSenderBlock)callback block:(resultCallBlcok)block {
    /*移动*/
    JVMobileUIConfig *mobileUIConfig = [[JVMobileUIConfig alloc] init];
    mobileUIConfig.logoImg = [UIImage imageNamed:@"native_login_icon"];
    mobileUIConfig.checkedImg=[UIImage imageNamed:@"checkBox_selected"];
    mobileUIConfig.uncheckedImg=[UIImage imageNamed:@"checkBox_unSelected"];
    mobileUIConfig.logoWidth=112;
    mobileUIConfig.logoHeight=42;
    mobileUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    mobileUIConfig.navColor= [UIColor whiteColor];
    mobileUIConfig.barStyle = 1;
    mobileUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    mobileUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    mobileUIConfig.sloganOffsetY=230;
    
    [JVERIFICATIONService customUIWithConfig:mobileUIConfig customViews:^(UIView *customAreaView) {
        CustomButton *lButton = [CustomButton initButtonWithFrame:CGRectMake(75, SCREEN_HEIGHT-300, 61, 60)  backgroundImage:[UIImage imageNamed:@"native_phone_number_login"] block:^{
            if (block) {
                block(LeftButton);
            }
        }];
        [customAreaView addSubview:lButton];
        
        CustomButton *rButton = [CustomButton initButtonWithFrame:CGRectMake(SCREEN_WIDTH-124, SCREEN_HEIGHT-300, 49, 60) backgroundImage:[UIImage imageNamed:@"native_wechat_login"] block:^{
            if (block) {
                block(RightButton);
            }
        }];
        [customAreaView addSubview:rButton];
        
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, SCREEN_HEIGHT-350, SCREEN_WIDTH-50, 35}];
        
        
        UIView *childViewLeft = [[UIView alloc] initWithFrame:(CGRect){0, 0, (SCREEN_WIDTH-50)/3.2, 0.8}];
        childViewLeft.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(243/255.0 ) blue:(243/255.0 ) alpha:(1/1.0)];
        childViewLeft.center = CGPointMake(childViewLeft.center.x, CGRectGetMidY(view.bounds));
        [view addSubview:childViewLeft];
        
        
        UIView *childViewRight = [[UIView alloc] initWithFrame:(CGRect){(SCREEN_WIDTH-50)-(SCREEN_WIDTH-50)/3.2, 0, (SCREEN_WIDTH-50)/3.2, 0.8}];
        childViewRight.backgroundColor =[UIColor colorWithRed:(243/255.0) green:(243/255.0 ) blue:(243/255.0 ) alpha:(1/1.0)];
        childViewRight.center = CGPointMake(childViewRight.center.x, CGRectGetMidY(view.bounds));
        [view addSubview:childViewRight];
        
        
        
        UILabel *childLabel = [[UILabel alloc] init];
        childLabel.text = @"其他登入方式";
        childLabel.font=[childLabel.font fontWithSize:14];
        childLabel.textColor = [UIColor colorWithRed:(152/255.0) green:(152/255.0 ) blue:(152/255.0 ) alpha:(1/1.0)];
        [childLabel sizeToFit];
        childLabel.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
        [view addSubview:childLabel];
        
        
        view.center = CGPointMake(CGRectGetMidX(customAreaView.bounds), view.center.y);
        [customAreaView addSubview:view];
    }];
    
    /*联通*/
    JVUnicomUIConfig *unicomUIConfig = [[JVUnicomUIConfig alloc] init];
    unicomUIConfig.logoImg = [UIImage imageNamed:@"native_login_icon"];
    unicomUIConfig.checkedImg=[UIImage imageNamed:@"checkBox_selected"];
    unicomUIConfig.uncheckedImg=[UIImage imageNamed:@"checkBox_unSelected"];
    unicomUIConfig.logoWidth=112;
    unicomUIConfig.logoHeight=42;
    unicomUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    unicomUIConfig.navColor= [UIColor whiteColor];
    unicomUIConfig.barStyle = 1;
    unicomUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    unicomUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    unicomUIConfig.sloganOffsetY=230;
    
    [JVERIFICATIONService customUIWithConfig:unicomUIConfig customViews:^(UIView *customAreaView) {
        CustomButton *lButton = [CustomButton initButtonWithFrame:CGRectMake(75, SCREEN_HEIGHT-300, 61, 60)  backgroundImage:[UIImage imageNamed:@"native_phone_number_login"] block:^{
            if (block) {
                block(LeftButton);
            }
        }];
        [customAreaView addSubview:lButton];
        
        CustomButton *rButton = [CustomButton initButtonWithFrame:CGRectMake(SCREEN_WIDTH-124, SCREEN_HEIGHT-300, 49, 60) backgroundImage:[UIImage imageNamed:@"native_wechat_login"] block:^{
            if (block) {
                block(RightButton);
            }
        }];
        [customAreaView addSubview:rButton];
        
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, SCREEN_HEIGHT-350, SCREEN_WIDTH-50, 35}];
        
        
        UIView *childViewLeft = [[UIView alloc] initWithFrame:(CGRect){0, 0, (SCREEN_WIDTH-50)/3.2, 0.8}];
        childViewLeft.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(243/255.0 ) blue:(243/255.0 ) alpha:(1/1.0)];
        childViewLeft.center = CGPointMake(childViewLeft.center.x, CGRectGetMidY(view.bounds));
        [view addSubview:childViewLeft];
        
        
        UIView *childViewRight = [[UIView alloc] initWithFrame:(CGRect){(SCREEN_WIDTH-50)-(SCREEN_WIDTH-50)/3.2, 0, (SCREEN_WIDTH-50)/3.2, 0.8}];
        childViewRight.backgroundColor =[UIColor colorWithRed:(243/255.0) green:(243/255.0 ) blue:(243/255.0 ) alpha:(1/1.0)];
        childViewRight.center = CGPointMake(childViewRight.center.x, CGRectGetMidY(view.bounds));
        [view addSubview:childViewRight];
        
        
        
        UILabel *childLabel = [[UILabel alloc] init];
        childLabel.text = @"其他登入方式";
        childLabel.font=[childLabel.font fontWithSize:14];
        childLabel.textColor = [UIColor colorWithRed:(152/255.0) green:(152/255.0 ) blue:(152/255.0 ) alpha:(1/1.0)];
        [childLabel sizeToFit];
        childLabel.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
        [view addSubview:childLabel];
        
        
        view.center = CGPointMake(CGRectGetMidX(customAreaView.bounds), view.center.y);
        [customAreaView addSubview:view];
    }];
    
    /*电信*/
    JVTelecomUIConfig *telecomUIConfig = [[JVTelecomUIConfig alloc] init];
    telecomUIConfig.checkedImg=[UIImage imageNamed:@"checkBox_selected"];
    telecomUIConfig.uncheckedImg=[UIImage imageNamed:@"checkBox_unSelected"];
    telecomUIConfig.logoImg = [UIImage imageNamed:@"native_login_icon"];
    telecomUIConfig.logoWidth=112;
    telecomUIConfig.logoHeight=42;
    telecomUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    telecomUIConfig.navColor= [UIColor whiteColor];
    telecomUIConfig.barStyle = 1;
    telecomUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    telecomUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    telecomUIConfig.sloganOffsetY=230;
    
    [JVERIFICATIONService customUIWithConfig:telecomUIConfig customViews:^(UIView *customAreaView) {
        
        CustomButton *lButton = [CustomButton initButtonWithFrame:CGRectMake(75, SCREEN_HEIGHT-300, 61, 60)  backgroundImage:[UIImage imageNamed:@"native_phone_number_login"] block:^{
            if (block) {
                block(LeftButton);
            }
        }];
        [customAreaView addSubview:lButton];
        
        CustomButton *rButton = [CustomButton initButtonWithFrame:CGRectMake(SCREEN_WIDTH-124, SCREEN_HEIGHT-300, 49, 60) backgroundImage:[UIImage imageNamed:@"native_wechat_login"] block:^{
            if (block) {
                block(RightButton);
            }
        }];
        [customAreaView addSubview:rButton];
        
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, SCREEN_HEIGHT-350, SCREEN_WIDTH-50, 35}];
        
        
        UIView *childViewLeft = [[UIView alloc] initWithFrame:(CGRect){0, 0, (SCREEN_WIDTH-50)/3.2, 0.8}];
        childViewLeft.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(243/255.0 ) blue:(243/255.0 ) alpha:(1/1.0)];
        childViewLeft.center = CGPointMake(childViewLeft.center.x, CGRectGetMidY(view.bounds));
        [view addSubview:childViewLeft];
        
        
        UIView *childViewRight = [[UIView alloc] initWithFrame:(CGRect){(SCREEN_WIDTH-50)-(SCREEN_WIDTH-50)/3.2, 0, (SCREEN_WIDTH-50)/3.2, 0.8}];
        childViewRight.backgroundColor =[UIColor colorWithRed:(243/255.0) green:(243/255.0 ) blue:(243/255.0 ) alpha:(1/1.0)];
        childViewRight.center = CGPointMake(childViewRight.center.x, CGRectGetMidY(view.bounds));
        [view addSubview:childViewRight];
        
        
        
        UILabel *childLabel = [[UILabel alloc] init];
        childLabel.text = @"其他登入方式";
        childLabel.font=[childLabel.font fontWithSize:14];
        childLabel.textColor = [UIColor colorWithRed:(152/255.0) green:(152/255.0 ) blue:(152/255.0 ) alpha:(1/1.0)];
        [childLabel sizeToFit];
        childLabel.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
        [view addSubview:childLabel];
        
        
        view.center = CGPointMake(CGRectGetMidX(customAreaView.bounds), view.center.y);
        [customAreaView addSubview:view];
        
    }];
    
    
}


@end
