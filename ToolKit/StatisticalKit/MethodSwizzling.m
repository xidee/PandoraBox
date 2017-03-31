//
//  MethodSwizzling.m
//  PandoraBox
//
//  Created by xidee on 2017/3/31.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "MethodSwizzling.h"
#import <objc/runtime.h>

@implementation MethodSwizzling

+ (void)swizzlingInClass:(Class)targatClass originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    //获取类的实例方法
    Method originalMethod = class_getInstanceMethod(targatClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(targatClass, swizzledSelector);
    
    //添加方法
    BOOL didAdd = class_addMethod(targatClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAdd) {
        //添加成功重写实现
        class_replaceMethod(targatClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        
    }else{
        //已经存在 替换实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

@end
