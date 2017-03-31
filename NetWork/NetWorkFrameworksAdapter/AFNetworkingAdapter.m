//
//  AFNetworkingAdapter.m
//  PandoraBox
//
//  Created by xidee on 2017/3/2.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "AFNetworkingAdapter.h"
#import <AFNetworking.h>
#import <XMLDictionary.h>

@implementation AFNetworkingAdapter

- (NSURLSessionDataTask *)requestWithHTTPMethod:(HTTPMethodEnum)HTTPMethod
                                      URLString:(NSString *)URLString
                                  configuration:(PandoraNetWorkConfiguration *)configuration
                                     parameters:(id)parameters
                                        success:(void(^)(NSURLSessionDataTask *task ,id responseObject))success
                                        failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
{
    //配置一些基本信息
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration.sessionConfiguration];
    if(configuration.responseSerializer == ResponseSerializer_XML){
        manager.responseSerializer = [[AFXMLParserResponseSerializer alloc] init];
    }else if(configuration.responseSerializer == ResponseSerializer_Data) {
        manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    }

    //JSON格式的参数 (非key value格式)
    if ([parameters isKindOfClass:[NSString class]]) {
        NSError *requestError;
        [manager.requestSerializer requestWithMethod:@"POST" URLString:URLString parameters:parameters error:&requestError];
        if (failure) {
            failure(nil,requestError);
        }
    }
    
    //根据http请求方式 发出对应的请求
    switch (HTTPMethod) {
        case HTTPMethod_Get:
        {
            return [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    if (configuration.responseSerializer == ResponseSerializer_XML && [responseObject isKindOfClass:[NSXMLParser class]]) {
                        //将XML数据 转换成字段 再往外抛
                        responseObject = [NSDictionary dictionaryWithXMLParser:responseObject];
                    }
                    success(task,responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(task,error);
                }
            }];
        }
            break;
        case HTTPMethod_Post:
        {
            return [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    if (configuration.responseSerializer == ResponseSerializer_XML && [responseObject isKindOfClass:[NSXMLParser class]]) {
                        //将XML数据 转换成字段 再往外抛
                        responseObject = [NSDictionary dictionaryWithXMLParser:responseObject];
                    }
                    success(task,responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(task,error);
                }
            }];
        }
            break;
        default:
            break;
    }
    return nil;
}


- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                    configuration:(PandoraNetWorkConfiguration *)configuration
                                         progress:( void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration.sessionConfiguration];
    return [manager uploadTaskWithRequest:request fromFile:fileURL progress:uploadProgressBlock completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                    configuration:(PandoraNetWorkConfiguration *)configuration
                                         progress:( void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration.sessionConfiguration];
    return [manager uploadTaskWithRequest:request fromData:bodyData progress:uploadProgressBlock completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                        configuration:(PandoraNetWorkConfiguration *)configuration
                                             progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL * filePath, NSError *error))completionHandler
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration.sessionConfiguration];
    return [manager downloadTaskWithRequest:request progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                           configuration:(PandoraNetWorkConfiguration *)configuration
                                                progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration.sessionConfiguration];
    return [manager downloadTaskWithResumeData:resumeData progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
}

@end
