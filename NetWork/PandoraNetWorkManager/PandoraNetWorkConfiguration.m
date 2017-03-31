//
//  PandoraNetWorkConfiguration.m
//  PandoraBox
//
//  Created by xidee on 2017/3/3.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraNetWorkConfiguration.h"

@implementation PandoraNetWorkConfiguration

//
- (NSURLSessionConfiguration *)sessionConfiguration
{
    if (!_sessionConfiguration) {
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _sessionConfiguration;
}

@end
