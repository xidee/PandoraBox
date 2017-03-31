//
//  PandoraNetWorkConfiguration.h
//  PandoraBox
//
//  Created by xidee on 2017/3/3.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  网络请求配置类

#import <Foundation/Foundation.h>

/**
 请求方式
 */
typedef enum {
    HTTPMethod_Get,
    HTTPMethod_Head,
    HTTPMethod_Post,
    HTTPMethod_Put,
    HTTPMethod_Patch,
    HTTPMethod_Delete
}HTTPMethodEnum;

/**
 响应数据格式
 */
typedef enum {
    ResponseSerializer_Data,
    ResponseSerializer_JSON,
    ResponseSerializer_XML
}ResponseSerializerEnum;

@interface PandoraNetWorkConfiguration : NSObject

/**
 配置数据相应格式 默认JSON
 */
@property (nonatomic ,assign) ResponseSerializerEnum responseSerializer;

/**
 会话配置信息
 */
@property (nonatomic ,strong) NSURLSessionConfiguration *sessionConfiguration;

@end
