//
//  YTURLProtocol.m
//  WebviewCache
//
//  Created by xidee on 16/3/31.
//  Copyright © 2016年 xidee All rights reserved.
//

#import "YTURLProtocol.h"
#import <UIKit/UIImage.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define YTurlfilterrule @"urlfilterrule"
#define URLINTECEPT YES //拦截url与否的开关----测试用
@interface YTURLProtocol ()<NSURLSessionDelegate>

@end

@implementation YTURLProtocol
//这个方法用来返回是否需要处理这个请求，如果需要处理，返回YES，否则返回NO。在该方法中可以对不需要处理的请求进行过滤。
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return YES;
}

//重写该方法，可以对请求进行修改，例如添加新的头部信息，修改，修改url等，返回修改后的请求。
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

//该方法主要用来判断两个请求是否是同一个请求，如果是，则可以使用缓存数据，通常只需要调用父类的实现即可
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:( NSURLRequest *)b
{
    return YES;
}

//重写该方法，需要在该方法中发起一个请求,就是发起一个NSURLSessionTask
- (void)startLoading
{
    //    NSLog(@"YTURLProtocol %@",self.request.URL.absoluteString);
    NSString *path;
    NSData *data;
    
    //取host 和 path 拼目录
    NSString *prefix = [self.request.URL.host stringByAppendingPathComponent:self.request.URL.path];
    //从应用沙盒当中取
    path = [H5ResourcePath stringByAppendingPathComponent:prefix];
    data = [NSData dataWithContentsOfFile:path];
    
    if (data) {
        //本地有数据直接作为结果返回给客户端
        NSDictionary *headerDic = @{@"contentType":[self getFileMIMETypeWithURL:path]};
        NSHTTPURLResponse *httpRes = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:200 HTTPVersion:@"" headerFields:headerDic];
        [[self client] URLProtocol:self didReceiveResponse:httpRes cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[self client] URLProtocol:self didLoadData:data];
        [[self client] URLProtocolDidFinishLoading:self];
    }
}

- (void)stopLoading
{
    
}

#pragma mark - tool methed
/**
 *  @Parma request 需要判断的REQUEST
 *  @return 是否需要拦截替换本地资源
 */
+ (BOOL)isReplaceByLocalDataWith:(NSURLRequest *)request
{
    NSArray *pathComponents = [request.URL.path componentsSeparatedByString:@"/"];
    if (pathComponents.count > 2) {
        NSString *part1InPath = [pathComponents objectAtIndex:1];
        if (part1InPath.length) {
            //过滤需要拦截的path ，true条件：文件存在 且为需要拦截的资源类型
            NSString *applicationRoot = [[request.URL.host stringByAppendingPathComponent:part1InPath]stringByAppendingString:@"/"];
            for (NSString *appName in [H5ResourceManager shared].applicationInfo.allKeys) {
                NSDictionary *appDic = [[H5ResourceManager shared].applicationInfo objectForKey:appName];
                if (appDic) {
                    if ([applicationRoot isEqualToString:[appDic objectForKey:@"applicationRootDir"]]) {
                        //取host 和 path 拼目录
                        NSString *prefix = [request.URL.host stringByAppendingPathComponent:request.URL.path];
                        //从应用沙盒当中取
                        NSString *path = [H5ResourcePath stringByAppendingPathComponent:prefix];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                            //取得URL的拓展 （转化成小写）判断是否为需要拦截的类型
                            return [[H5ResourceManager shared].manifest containsObject:request.URL.pathExtension.lowercaseString];
                        }
                    }
                }
            }
        }
    }
    //本地已有的资源拦截 截获请求
    return [[H5ResourceManager shared].localArr containsObject:request.URL.absoluteString];
}

/*
 *  @return 根据本地文件获取文件的MIMEType C的方法
 */
- (NSString *)getFileMIMETypeWithURL :(NSString *)path
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}

@end
