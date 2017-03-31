//
//  PandoraNotificationManager.m
//  PandoraBox
//
//  Created by xidee on 2017/3/22.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraNotificationManager.h"

@implementation PandoraNotificationManager

- (void)registerNotificationSettings:(UIUserNotificationSettings *)settings
{
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (void)send
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
