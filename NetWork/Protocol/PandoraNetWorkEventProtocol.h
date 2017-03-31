//
//  PandoraLoadingViewProtocol.h
//  PandoraBox
//
//  Created by xidee on 2017/3/6.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  任务期间的一些事件

#import <Foundation/Foundation.h>

@protocol PandoraNetWorkEventProtocol <NSObject>

@optional

/**
 任务启动时调用
 @param task 任务
 */
- (void)taskDidBegin:(NSURLSessionTask *)task;


/**
 任务结束时调用
 @param task 任务
 @param error 错误信息
 */
- (void)taskDidComplete:(NSURLSessionTask *)task error:(NSError *)error;

@end
