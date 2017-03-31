//
//  PandoraImageLoader.m
//  PandoraBox
//
//  Created by xidee on 2017/3/7.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraImageLoader.h"

@interface PandoraImageLoader ()

@property (nonatomic ,strong) id <PandoraImageLoaderProtocol>protocol;

@end

@implementation PandoraImageLoader

+ (instancetype)sharedLoader
{
    static PandoraImageLoader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PandoraImageLoader alloc] init];
    });
    return instance;
}

- (BOOL)registerProtocol:(Class)protocol
{
    if(protocol && [protocol conformsToProtocol:@protocol(PandoraImageLoaderProtocol)])
    {
        self.protocol = [[protocol alloc] init];
        return YES;
    }
    return NO;
}

+ (UIImage *)loadImageFromLocalPath:(NSString *)path
{
    return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)loadImageFromBoundle:(NSBundle *)bundle withFileName:(NSString *)fileName andExpansion:(NSString *)expansion
{
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    NSString *path = [bundle pathForResource:fileName ofType:expansion];
    return [UIImage imageWithContentsOfFile:path];
}

//通过协议实现方下载图片并返回结果
- (void)downloadImageWithURL:(NSURL *)URL progress:(void(^)(NSProgress *progress))progressBlock completed:(void(^)(UIImage *image,NSError *error,BOOL finished))completedBlock
{
    if (self.protocol && [self.protocol respondsToSelector:@selector(downloadImageWithURL:progress:completed:)]) {
        [self.protocol downloadImageWithURL:URL progress:progressBlock completed:completedBlock];
    }
}
//直接给imageView设置image的方法
- (void)setImageForImageView:(UIImageView *)imageView WithURL:(NSURL *)URL placeholderImage:(UIImage *)placeholder
{
    if (placeholder) {
        [imageView setImage:placeholder];
    }
    [self downloadImageWithURL:URL progress:nil completed:^(UIImage *image, NSError *error, BOOL finished) {
        if (finished && image && !error) {
            [imageView setImage:image];
        }
    }];
}

@end
