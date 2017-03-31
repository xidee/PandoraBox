//
//  PandoraImageLoaderProtocol.h
//  PandoraBox
//
//  Created by xidee on 2017/3/7.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PandoraImageLoaderProtocol <NSObject>

@required
/**
 图片下载协议
 @param URL 图片地址
 @param progressBlock 进度回调
 @param completedBlock 完成回调
 */
- (void)downloadImageWithURL:(NSURL *)URL progress:(void(^)(NSProgress *progress))progressBlock completed:(void(^)(UIImage *image,NSError *error,BOOL finished))completedBlock;

@end
