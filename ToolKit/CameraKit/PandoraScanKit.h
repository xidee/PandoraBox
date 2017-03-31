//
//  PandoraScanKit.h
//  PandoraBox
//
//  Created by xidee on 2017/3/17.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  扫描工具类

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef void (^PandoraScanResult)(NSString * type,NSString *result);

@interface PandoraScanKit : NSObject<AVCaptureMetadataOutputObjectsDelegate>

/**
    扫描结果block回调
 */
@property (nonatomic ,copy) PandoraScanResult result;

/**
    镜头焦距（默认1.5）
 */
@property (nonatomic ,assign) CGFloat videoZoomFactor;

/**
    设置扫码类型 （没有设置将支持所有类型 对应降低扫描速度）
 */
@property (nonatomic ,strong) NSArray *metadataObjectTypes;

/**
 初始化方法
 @param superView 加载预览图层的视图
 @return 返回实例
 */
- (instancetype)initSessionInView:(UIView *)superView;

/**
    开始扫描
 */
- (void)startScan;

/**
    停止扫描
 */
- (void)stopScan;

@end
