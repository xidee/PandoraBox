//
//  PandoraNetWork.m
//  PandoraBox
//
//  Created by xidee on 2017/3/2.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraNetWork.h"

@interface PandoraNetWork()

@property (nonatomic ,strong) id<PandoraNetWorkProtocol>netWorkProtocol;
@property (nonatomic ,strong) id<PandoraNetWorkEventProtocol>netEventProtocol;

@end

@implementation PandoraNetWork

+ (instancetype)sharedNetWork
{
    static PandoraNetWork *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PandoraNetWork alloc] init];
        PandoraNetWorkConfiguration *configuration = [[PandoraNetWorkConfiguration alloc] init];
        //默认JSON格式响应
        configuration.responseSerializer = ResponseSerializer_JSON;
        //设置一个默认的配置
        configuration.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //设置60S超时
        configuration.sessionConfiguration.timeoutIntervalForRequest = 60;
        instance.configuration = configuration;
    });
    return instance;
}

- (void)setCachePoolWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity
{
    NSURLCache *cachePool = [NSURLCache sharedURLCache];
    cachePool.memoryCapacity = memoryCapacity;
    cachePool.diskCapacity = diskCapacity;
}

- (BOOL)registerNetAdapter:(Class)protocol
{
    //判断适配器 有没有实现相关网络请求协议 返回注册结果
    if ([protocol conformsToProtocol:@protocol(PandoraNetWorkProtocol)]) {
        self.netWorkProtocol = [[protocol alloc]init];
        return YES;
    }
    return NO;
}

- (BOOL)registerEventRespond:(Class)respond
{
    //判断注册类有没有实现 事件处理协议 返回注册结果
    if ([respond conformsToProtocol:@protocol(PandoraNetWorkEventProtocol)]) {
        self.netEventProtocol = [[respond alloc] init];
        return YES;
    }
    return NO;
}

#pragma mark - 协议方发起请求
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //使用默认配置的get请求
    return [self GET:URLString parameters:parameters configuration:self.configuration success:success failure:failure];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                configuration:(PandoraNetWorkConfiguration *)configuration
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //可配置的get请求
    return [self requestWithHTTPMethod:HTTPMethod_Get URLString:URLString configuration:configuration parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //使用默认配置的POST请求
    return [self POST:URLString parameters:parameters configuration:self.configuration success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                 configuration:(PandoraNetWorkConfiguration *)configuration
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //可配置的POST请求
    return [self requestWithHTTPMethod:HTTPMethod_Post URLString:URLString configuration:configuration parameters:parameters success:success failure:failure];
}

//调用协议实现方
- (NSURLSessionDataTask *)requestWithHTTPMethod:(HTTPMethodEnum)HTTPMethod
                                      URLString:(NSString *)URLString
                                  configuration:(PandoraNetWorkConfiguration *)configuration
                                     parameters:(id)parameters
                                        success:(void(^)(NSURLSessionDataTask *task ,id responseObject))success
                                        failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    if (self.netWorkProtocol && [self.netWorkProtocol respondsToSelector:@selector(requestWithHTTPMethod:URLString:configuration:parameters:success:failure:)]) {
        
        NSURLSessionDataTask *task = [self.netWorkProtocol requestWithHTTPMethod:HTTPMethod URLString:URLString configuration:configuration parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            //通知任务实现方  任务结束
            if (self.netEventProtocol && [self.netEventProtocol respondsToSelector:@selector(taskDidComplete:error:)]) {
                [self.netEventProtocol taskDidComplete:task error:nil];
            }
            //数据回调
            if (success) {
                success(task,responseObject);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            //通知任务实现方  任务结束
            if (self.netEventProtocol && [self.netEventProtocol respondsToSelector:@selector(taskDidComplete:error:)]) {
                [self.netEventProtocol taskDidComplete:task error:error];
            }
            //数据回调
            if (failure) {
                failure(task,error);
            }
        }];
        //通知协议实现方 任务开始
        if (self.netEventProtocol && [self.netEventProtocol respondsToSelector:@selector(taskDidBegin:)]) {
            [self.netEventProtocol taskDidBegin:task];
        }
    }
    return nil;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                    configuration:(PandoraNetWorkConfiguration *)configuration
                                         progress:( void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    if (self.netWorkProtocol && [self.netWorkProtocol respondsToSelector:@selector(uploadTaskWithRequest:fromFile:configuration:progress:completionHandler:)]) {
        return [self.netWorkProtocol uploadTaskWithRequest:request fromFile:fileURL configuration:configuration progress:uploadProgressBlock completionHandler:completionHandler];
    }
    return nil;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                    configuration:(PandoraNetWorkConfiguration *)configuration
                                         progress:( void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    if (self.netWorkProtocol && [self.netWorkProtocol respondsToSelector:@selector(uploadTaskWithRequest:fromData:configuration:progress:completionHandler:)]) {
        return [self.netWorkProtocol uploadTaskWithRequest:request fromData:bodyData configuration:configuration progress:uploadProgressBlock completionHandler:completionHandler];
    }
    return nil;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                        configuration:(PandoraNetWorkConfiguration *)configuration
                                             progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL * filePath, NSError *error))completionHandler
{
    if (self.netWorkProtocol && [self.netWorkProtocol respondsToSelector:@selector(downloadTaskWithRequest:configuration:progress:destination:completionHandler:)]) {
        return [self.netWorkProtocol downloadTaskWithRequest:request configuration:configuration progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    }
    return nil;
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                           configuration:(PandoraNetWorkConfiguration *)configuration
                                                progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    if (self.netWorkProtocol && [self.netWorkProtocol respondsToSelector:@selector(downloadTaskWithResumeData:configuration:progress:destination:completionHandler:)]) {
        return [self.netWorkProtocol downloadTaskWithResumeData:resumeData configuration:configuration progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    }
    return nil;
}

@end
