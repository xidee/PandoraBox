//
//  MethodSwizzling.h
//  PandoraBox
//
//  Created by xidee on 2017/3/31.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  方法注入工具

#import <Foundation/Foundation.h>

@interface MethodSwizzling : NSObject


/**
 方法注入 替换
 @param targatClass 需要操作的目标类
 @param originalSelector 需要替换的原始方法
 @param swizzledSelector 被替换的新方法
 */
+ (void)swizzlingInClass:(Class)targatClass originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end
