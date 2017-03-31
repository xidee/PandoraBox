//
//  AFNetworkingAdapter.h
//  PandoraBox
//
//  Created by xidee on 2017/3/2.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  AFNetWorking 适配器 实现网络协议 + XML解析

#import <Foundation/Foundation.h>   
#import "PandoraNetWorkProtocol.h"

@interface AFNetworkingAdapter : NSObject <PandoraNetWorkProtocol>

@end
