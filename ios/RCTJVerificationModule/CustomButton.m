//
//  CustomButton.m
//  custombutton
//
//  Created by 吕家昊 on 2019/4/15.
//  Copyright © 2019 吕家昊. All rights reserved.
//

#import "CustomButton.h"
#import <objc/runtime.h>

static const char btnBlock;

@implementation CustomButton

@dynamic buttonClickBlock;


- (void)setButtonClickBlock:(ButtonClickBlcok)buttonClickBlock {
    objc_setAssociatedObject(self, &btnBlock, buttonClickBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(ButtonSenderOpen) forControlEvents:(UIControlEventTouchUpInside)];
}

- (ButtonClickBlcok)buttonClickBlock {
    return objc_getAssociatedObject(self, &btnBlock);
}

- (void)ButtonSenderOpen{
    if (self.buttonClickBlock) {
        self.buttonClickBlock();
    }
}

+ (instancetype)initButtonWithFrame:(CGRect)frame backgroundImage:(UIImage *)backgroundImage block:(ButtonClickBlcok)block {
    CustomButton *btn = [[CustomButton alloc] initWithFrame:frame];
    [btn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    btn.buttonClickBlock = ^() {
        block();
    };
    return btn;
}

@end
