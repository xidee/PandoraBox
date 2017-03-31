//
//  SDWebImageAdapter.m
//  PandoraBox
//
//  Created by xidee on 2017/3/7.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "SDWebImageAdapter.h"
#import <SDWebImageDownloader.h>

@implementation SDWebImageAdapter

- (void)downloadImageWithURL:(NSURL *)URL progress:(void (^)(NSProgress *))progressBlock completed:(void (^)(UIImage *, NSError *, BOOL))completedBlock
{
    __block NSProgress *progress;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:URL options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progressBlock) {
            //回调进度
            if (!progress) {
                progress = [NSProgress progressWithTotalUnitCount:expectedSize];
            }
            progress.completedUnitCount = receivedSize;
            progressBlock(progress);
        }
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (completedBlock) {
            //回调结果
            completedBlock(image,error,finished);
        }
    }];
}

@end
