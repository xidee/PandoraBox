//
//  UIControl+statistical.m
//  PandoraBox
//
//  Created by xidee on 2017/3/31.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "UIControl+statistical.h"
#import "MethodSwizzling.h"
#import "UserStatisticManager.h"

@implementation UIControl (statistical)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MethodSwizzling swizzlingInClass:[self class] originalSelector:@selector(sendAction:to:forEvent:) swizzledSelector:@selector(statistical_sendAction:to:forEvent:)];
    });
}

//替换方法
- (void)statistical_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    //代码注入 （指业务在响应按钮点击 时候想要做的事情）
    [self injectAction:action to:target forEvent:event];
    //调用sendAction:to:forEvent: (注：此时下面这个实现IMP是指向原来的sendAction:to:forEvent:)
    [self statistical_sendAction:action to:target forEvent:event];
}

//注入内容
- (void)injectAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    UserStatisticManager *manager = [UserStatisticManager shareManager];
    if (manager.protocol && [manager.protocol respondsToSelector:@selector(controlAction:target:)]) {
        [manager.protocol controlAction:NSStringFromSelector(action) target:NSStringFromClass([target class])];
    }
    if (manager.debugLog) {
        NSLog(@"UserStatisticManager: 目标%@ 响应用户操作%@",[target class],NSStringFromSelector(action));
    }
}

@end
