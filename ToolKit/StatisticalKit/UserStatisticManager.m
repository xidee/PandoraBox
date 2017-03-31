//
//  UserStatisticManager.m
//  PandoraBox
//
//  Created by xidee on 2017/3/31.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "UserStatisticManager.h"

@implementation UserStatisticManager

+ (instancetype)shareManager
{
    static UserStatisticManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserStatisticManager alloc] init];
        manager.debugLog = YES;
    });
    return manager;
}

@end
