//
//  PandoraNetWorkProtocol.h
//  PandoraBox
//
//  Created by xidee on 2017/2/28.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  网络请求协议 （需要网络请求框架 实现）

/**
 *  协议方法 包含基础的 请求方法 上传下载方法  
 */

#import <Foundation/Foundation.h>
#import "PandoraNetWorkConfiguration.h"

@protocol PandoraNetWorkProtocol <NSObject>

@required

/**
 Http请求 协议
 @param HTTPMethod HTTP请求方式 参考枚举 HTTPMethod
 @param URLString 请求的URL字符串
 @param configuration 请求配置信息
 @param parameters 查询参数
 @param success 成功block
 @param failure 失败block
 @return 此次会话任务 
 */
- (NSURLSessionDataTask *)requestWithHTTPMethod:(HTTPMethodEnum)HTTPMethod
                                      URLString:(NSString *)URLString
                                  configuration:(PandoraNetWorkConfiguration *)configuration
                                     parameters:(id)parameters
                                        success:(void(^)(NSURLSessionDataTask *task ,id responseObject))success
                                        failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
@optional

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
