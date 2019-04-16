//
//  CustomButton.h
//  custombutton
//
//  Created by 吕家昊 on 2019/4/15.
//  Copyright © 2019 吕家昊. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ButtonClickBlcok) (void);

@interface CustomButton : UIButton

@property (nonatomic, copy) ButtonClickBlcok buttonClickBlock;

+ (instancetype)initButtonWithFrame:(CGRect)frame backgroundImage:(UIImage *)backgroundImage block:(ButtonClickBlcok)block;

@end

NS_ASSUME_NONNULL_END
