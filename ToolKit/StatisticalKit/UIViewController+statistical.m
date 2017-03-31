//
//  UIViewController+statistical.m
//  PandoraBox
//
//  Created by xidee on 2017/3/31.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "UIViewController+statistical.h"
#import "MethodSwizzling.h"
#import "UserStatisticManager.h"

@implementation UIViewController (statistical)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MethodSwizzling swizzlingInClass:[self class] originalSelector:@selector(viewWillAppear:) swizzledSelector:@selector(statistical_viewWillAppear:)];
        [MethodSwizzling swizzlingInClass:[self class] originalSelector:@selector(viewWillDisappear:) swizzledSelector:@selector(statistical_viewWillDisappear:)];
    });
}

- (void)statistical_viewWillAppear:(BOOL)animated
{
    //代码注入 （指业务在viewWillAppear 时候想要做的事情）
    [self inject_viewWillAppear];
    //调用viewWillAppear (注：此时下面这个实现IMP是指向原来的viewWillAppear)
    [self statistical_viewWillAppear:animated];
}

- (void)statistical_viewWillDisappear:(BOOL)animated
{
    [self inject_viewWillDisappear];
    [self statistical_viewWillDisappear:animated];
}

//进入页面代码注入
- (void)inject_viewWillAppear
{
    //通知统计工具类的协议实现方进入页面
    UserStatisticManager *manager = [UserStatisticManager shareManager];
    if (manager.protocol && [manager.protocol respondsToSelector:@selector(enterPageWithClass:)]) {
        [manager.protocol enterPageWithClass:NSStringFromClass([self class])];
    }
    if (manager.debugLog) {
        NSLog(@"UserStatisticManager：进入页面%@",[self class]);
    }
}
//离开页面代码注入
- (void)inject_viewWillDisappear
{
    //通知统计工具类的协议实现方离开页面
    UserStatisticManager *manager = [UserStatisticManager shareManager];
    if (manager.protocol && [manager.protocol respondsToSelector:@selector(leavePageWithClass:)]) {
        [manager.protocol leavePageWithClass:NSStringFromClass([self class])];
    }
    if(manager.debugLog){
        NSLog(@"UserStatisticManager：离开页面%@",[self class]);
    }
}


@end
