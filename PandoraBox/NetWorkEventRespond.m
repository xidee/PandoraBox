//
//  NetWorkEventRespond.m
//  PandoraBox
//
//  Created by xidee on 2017/3/7.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "NetWorkEventRespond.h"

@implementation NetWorkEventRespond


- (void)taskDidBegin:(NSURLSessionTask *)task
{
    NSLog(@"begin=====>%@",task.currentRequest.URL.absoluteString);
}

- (void)taskDidComplete:(NSURLSessionTask *)task error:(NSError *)error
{
    NSLog(@"end=====>%@",task.currentRequest.URL.absoluteString);
}

@end
