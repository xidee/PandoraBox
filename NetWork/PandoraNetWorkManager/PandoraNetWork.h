//
//  PandoraNetWork.h
//  PandoraBox
//
//  Created by xidee on 2017/3/2.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  对网络框架解耦的请求工具类

#import <Foundation/Foundation.h>
#import "PandoraNetWorkProtocol.h"
#import "PandoraNetWorkEventProtocol.h"

#define Megabyte(a) a*1024*1024  //兆字节的宏定义

@interface PandoraNetWork : NSObject

/**
    配置信息 （接口请求如果不传配置信息 将使用这个默认配置）
 */
@property (nonatomic,strong) PandoraNetWorkConfiguration *configuration;

/**
 初始化网络单例类
 @return 返回工具类单例
 */
+ (instancetype)sharedNetWork;

/**
 注册协议实现方 （实现 PandoraNetWorkProtocol）
 @param protocol 协议实现方
 @return 注册结果
 */
- (BOOL)registerNetAdapter:(Class)protocol;


/**
 注册事件响应协议实现放 （实现 PandoraNetEventProtocol）
 @param respond 事件响应者
 @return 注册结果
 */
- (BOOL)registerEventRespond:(Class)respond;

/**
 初始化缓存池
 @param memoryCapacity 内存缓存大小
 @param diskCapacity 磁盘缓存大小
 */
- (void)setCachePoolWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity;

#pragma mark - requestMethod

/**
 使用默认配置的GET请求方法
 @param URLString 请求URL
 @param parameters 查询参数
 @param success 成功回调
 @param failure 失败回调
 @return 返回此次会话任务对象
 */
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 可配置的GET请求方法
 @param URLString 请求URL
 @param parameters 查询参数
 @param configuration 任务配置信息
 @param success 成功回调
 @param failure 失败回调
 @return 返回此次会话任务对象
 */
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                configuration:(PandoraNetWorkConfiguration *)configuration
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 使用默认配置的POST方法
 @param URLString  请求URL
 @param parameters 查询参数
 @param success 成功回调
 @param failure 失败回调
 @return 返回此次会话任务对象
 */
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 可配置的POST请求方法
 @param URLString 请求URL
 @param parameters 查询参数
 @param configuration 任务配置信息
 @param success 成功回调
 @param failure 失败回调
 @return 返回此次会话任务对象
 */
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                 configuration:(PandoraNetWorkConfiguration *)configuration
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 上传本地文件协议
 @param request 由URL构建的request
 @param configuration 任务配置信息
 @param fileURL 文件路径
 @param uploadProgressBlock 上传进度回调
 @param completionHandler 完成回调
 @return 此次上传任务
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                    configuration:(PandoraNetWorkConfiguration *)configuration
                                         progress:( void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;
/**
 上传data协议
 @param request 由URL构建的request
 @param configuration 任务配置信息
 @param bodyData 二进制文件
 @param uploadProgressBlock 上传进度回调
 @param completionHandler 完成回调
 @return 此次上传任务
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                    configuration:(PandoraNetWorkConfiguration *)configuration
                                         progress:( void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

/**
 下载文件协议
 @param request 由URL构建的request
 @param configuration 任务配置信息
 @param downloadProgressBlock 下载进度回调
 @param destination 文件存储地址
 @param completionHandler 完成回调
 @return 此次下载任务
 */
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                        configuration:(PandoraNetWorkConfiguration *)configuration
                                             progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL * filePath, NSError *error))completionHandler;
/**
 断点续传协议
 @param resumeData 未完成下载文件的二进制流
 @param configuration 任务配置信息
 @param downloadProgressBlock 下载进度回调
 @param destination 文件存储地址
 @param completionHandler 完成回调
 @return 此次下载任务
 */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                           configuration:(PandoraNetWorkConfiguration *)configuration
                                                progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

@end
