//
//  PandoraImageLoader.h
//  PandoraBox
//
//  Created by xidee on 2017/3/7.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PandoraImageLoaderProtocol.h"

@interface PandoraImageLoader : NSObject

/**
 获取图片加载器单例
 @return 返回图片加载器单例对象
 */
+ (instancetype)sharedLoader;

/**
 注册图片下载协议实现类
 @param protocol 协议实现类
 @return 注册结果
 */
- (BOOL)registerProtocol:(Class)protocol;

/**
 从本地加载图片
 @param path 路径
 @return 图片
 */
+ (UIImage *)loadImageFromLocalPath:(NSString *)path;

/**
 从项目目录中加载图片
 @param bundle 图片所在的bundle
 @param fileName 图片名称
 @param expansion 图片扩展名
 @return 图片
 */
+ (UIImage *)loadImageFromBoundle:(NSBundle *)bundle withFileName:(NSString *)fileName andExpansion:(NSString *)expansion;

/**
 图片下载
 @param URL 图片地址
 @param progressBlock 进度回调
 @param completedBlock 结果回调
 */
- (void)downloadImageWithURL:(NSURL *)URL progress:(void(^)(NSProgress *progress))progressBlock completed:(void(^)(UIImage *image,NSError *error,BOOL finished))completedBlock;

/**
 给imageView设置网络图片
 @param imageView 需要设置的控件
 @param URL 图片地址
 @param placeholder 默认图
 */
- (void)setImageForImageView:(UIImageView *)imageView WithURL:(NSURL *)URL placeholderImage:(UIImage *)placeholder;

@end
