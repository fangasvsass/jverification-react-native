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
    mobileUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    mobileUIConfig.navColor= [UIColor whiteColor];
    mobileUIConfig.barStyle = 1;
    mobileUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    mobileUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    
    /*
     mobileUIConfig.navColor = [UIColor redColor];
     mobileUIConfig.barStyle = 0;
     mobileUIConfig.navText = [[NSAttributedString alloc] initWithString:@"自定义标题"];
     mobileUIConfig.navReturnImg = [UIImage imageNamed:@"自定义返回键"];
     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake(0, 0, 44, 44);
     button.backgroundColor = [UIColor greenColor];
     mobileUIConfig.navControl = [[UIBarButtonItem alloc] initWithCustomView:button];
     mobileUIConfig.logoWidth = 100;
     mobileUIConfig.logoHeight = 100;
     mobileUIConfig.logoOffsetY = 50;
     mobileUIConfig.logoHidden = NO;
     mobileUIConfig.logBtnText = @"自定义登录按钮文字";
     mobileUIConfig.logoOffsetY = 100;
     mobileUIConfig.logBtnTextColor = [UIColor redColor];
     mobileUIConfig.numberColor = [UIColor blueColor];
     mobileUIConfig.numFieldOffsetY = 80;
     mobileUIConfig.uncheckedImg = [UIImage imageNamed:@"未选中图片"];
     mobileUIConfig.checkedImg = [UIImage imageNamed:@"选中图片"];
     mobileUIConfig.appPrivacyOne = @[@"应用自定义服务条款1",@"https://www.jiguang.cn/about"];
     mobileUIConfig.appPrivacyTwo = @[@"应用自定义服务条款2",@"https://www.jiguang.cn/about"];
     mobileUIConfig.appPrivacyColor = @[[UIColor redColor], [UIColor blueColor]];
     mobileUIConfig.privacyOffsetY = 20;
     mobileUIConfig.sloganOffsetY = 70;
     mobileUIConfig.sloganTextColor = [UIColor redColor];
     */
    [JVERIFICATIONService customUIWithConfig:mobileUIConfig customViews:^(UIView *customAreaView) {
        CustomButton *button = [CustomButton initButtonWithFrame:CGRectMake(50, 500, 60, 60)  backgroundImage:[UIImage imageNamed:@"native_phone_number_login"] block:^{
            if (block) {
                block(LeftButton);
            }
        }];
        [customAreaView addSubview:button];
        
        CustomButton *button2 = [CustomButton initButtonWithFrame:CGRectMake(250, 500, 60, 60) backgroundImage:[UIImage imageNamed:@"native_wechat_login"] block:^{
            if (block) {
                block(RightButton);
            }
        }];
        [customAreaView addSubview:button2];
    }];
    
    /*联通*/
    JVUnicomUIConfig *unicomUIConfig = [[JVUnicomUIConfig alloc] init];
    unicomUIConfig.logoImg = [UIImage imageNamed:@"native_login_icon"];
    unicomUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    unicomUIConfig.navColor= [UIColor whiteColor];
    unicomUIConfig.barStyle = 1;
    unicomUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    unicomUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    /*
     unicomUIConfig.navColor = [UIColor redColor];
     unicomUIConfig.barStyle = 0;
     unicomUIConfig.navText = [[NSAttributedString alloc] initWithString:@"自定义标题"];
     unicomUIConfig.navReturnImg = [UIImage imageNamed:@"自定义返回键"];
     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake(0, 0, 44, 44);
     button.backgroundColor = [UIColor greenColor];
     unicomUIConfig.navControl = [[UIBarButtonItem alloc] initWithCustomView:button];
     unicomUIConfig.logoWidth = 100;
     unicomUIConfig.logoHeight = 100;
     unicomUIConfig.logoOffsetY = 50;
     unicomUIConfig.logoHidden = NO;
     unicomUIConfig.logBtnText = @"自定义登录按钮文字";
     unicomUIConfig.logoOffsetY = 100;
     unicomUIConfig.logBtnTextColor = [UIColor redColor];
     unicomUIConfig.numberColor = [UIColor blueColor];
     unicomUIConfig.numFieldOffsetY = 80;
     unicomUIConfig.uncheckedImg = [UIImage imageNamed:@"未选中图片"];
     unicomUIConfig.checkedImg = [UIImage imageNamed:@"选中图片"];
     unicomUIConfig.appPrivacyOne = @[@"应用自定义服务条款1",@"https://www.jiguang.cn/about"];
     unicomUIConfig.appPrivacyTwo = @[@"应用自定义服务条款2",@"https://www.jiguang.cn/about"];
     unicomUIConfig.appPrivacyColor = @[[UIColor redColor], [UIColor blueColor]];
     unicomUIConfig.privacyOffsetY = 20;
     unicomUIConfig.sloganOffsetY = 70;
     unicomUIConfig.sloganTextColor = [UIColor redColor];
     */
    [JVERIFICATIONService customUIWithConfig:unicomUIConfig customViews:^(UIView *customAreaView) {
        //添加自定义控件
        CustomButton *button = [CustomButton initButtonWithFrame:CGRectMake(50, 500, 60, 60)  backgroundImage:[UIImage imageNamed:@"native_phone_number_login"] block:^{
            if (block) {
                block(LeftButton);
            }
        }];
        [customAreaView addSubview:button];
        
        CustomButton *button2 = [CustomButton initButtonWithFrame:CGRectMake(250, 500, 60, 60) backgroundImage:[UIImage imageNamed:@"native_wechat_login"] block:^{
            if (block) {
                block(RightButton);
            }
        }];
        [customAreaView addSubview:button2];
    }];
    
    /*电信*/
    JVTelecomUIConfig *telecomUIConfig = [[JVTelecomUIConfig alloc] init];
    telecomUIConfig.logoImg = [UIImage imageNamed:@"native_login_icon"];
    telecomUIConfig.navText = [[NSAttributedString alloc] initWithString:@""];
    telecomUIConfig.navColor= [UIColor whiteColor];
    telecomUIConfig.barStyle = 1;
    telecomUIConfig.navReturnImg = [UIImage imageNamed:@"native_close"];
    telecomUIConfig.logBtnImgs= @[[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"],[UIImage imageNamed:@"native_login_bg"]];
    /*
     telecomUIConfig.navColor = [UIColor redColor];
     telecomUIConfig.barStyle = 0;
     telecomUIConfig.navText = [[NSAttributedString alloc] initWithString:@"自定义标题"];
     telecomUIConfig.navReturnImg = [UIImage imageNamed:@"自定义返回键"];
     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake(0, 0, 44, 44);
     button.backgroundColor = [UIColor greenColor];
     telecomUIConfig.navControl = [[UIBarButtonItem alloc] initWithCustomView:button];
     telecomUIConfig.logoWidth = 100;
     telecomUIConfig.logoHeight = 100;
     telecomUIConfig.logoOffsetY = 50;
     telecomUIConfig.logoHidden = NO;
     telecomUIConfig.logBtnText = @"自定义登录按钮文字";
     telecomUIConfig.logoOffsetY = 100;
     telecomUIConfig.logBtnTextColor = [UIColor redColor];
     telecomUIConfig.numberColor = [UIColor blueColor];
     telecomUIConfig.numFieldOffsetY = 80;
     telecomUIConfig.uncheckedImg = [UIImage imageNamed:@"未选中图片"];
     telecomUIConfig.checkedImg = [UIImage imageNamed:@"选中图片"];
     telecomUIConfig.appPrivacyOne = @[@"应用自定义服务条款1",@"https://www.jiguang.cn/about"];
     telecomUIConfig.appPrivacyTwo = @[@"应用自定义服务条款2",@"https://www.jiguang.cn/about"];
     telecomUIConfig.appPrivacyColor = @[[UIColor redColor], [UIColor blueColor]];
     telecomUIConfig.privacyOffsetY = 20;
     telecomUIConfig.sloganOffsetY = 70;
     telecomUIConfig.sloganTextColor = [UIColor redColor];
     */
    [JVERIFICATIONService customUIWithConfig:telecomUIConfig customViews:^(UIView *customAreaView) {
        
        /*
         UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
         button.frame = CGRectMake(50, 300, 44, 44);
         button.backgroundColor = [UIColor redColor];
         [button addTarget:self action:@selector(buttonTouch) forControlEvents:UIControlEventTouchUpInside];
         [customAreaView addSubview:button];
         */
        CustomButton *button = [CustomButton initButtonWithFrame:CGRectMake(50, 500, 60, 60)  backgroundImage:[UIImage imageNamed:@"native_phone_number_login"] block:^{
            if (block) {
                block(LeftButton);
            }
        }];
        [customAreaView addSubview:button];
        
        CustomButton *button2 = [CustomButton initButtonWithFrame:CGRectMake(250, 500, 60, 60) backgroundImage:[UIImage imageNamed:@"native_wechat_login"] block:^{
            if (block) {
                block(RightButton);
            }
        }];
        [customAreaView addSubview:button2];
        
    }];
    
    
}


@end
