//
//  UserStatisticManager.h
//  PandoraBox
//
//  Created by xidee on 2017/3/31.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  用户行为统计工具类

#import <Foundation/Foundation.h>

@protocol UserStatisticProtocol <NSObject>

/**
 进入目标页面调用
 @param target 目标页面类
 */
- (void)enterPageWithClass:(NSString*)target;
/**
 离开目标页面调用
 @param target 目标页面类
 */
- (void)leavePageWithClass:(NSString*)target;

/**
 控件响应用户操作时候调用
 @param action 响应的方法
 @param target 响应的页面
 */
- (void)controlAction:(NSString *)action target:(NSString* )target;

@end

@interface UserStatisticManager : NSObject

/**
    管理类协议实现方 赋值后在相关协议方法中进行行为统计即可
 */
@property (nonatomic ,weak) id<UserStatisticProtocol>protocol;

/**
    是否打印日子输出 （默认不打印）
 */
@property (nonatomic ,assign) BOOL debugLog;

+ (instancetype)shareManager;

@end
