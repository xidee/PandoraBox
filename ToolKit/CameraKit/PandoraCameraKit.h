//
//  PandoraCameraKit.h
//  PandoraBox
//
//  Created by xidee on 2017/3/17.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^PandoraCameraResult)(UIImage *image);

@interface PandoraCameraKit : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/**
 弹出系统图片选择器
 @param sourceType 图片来源 相机或者相册
 @param viewController 弹出的界面 (必须持有PandoraCameraKit 实例，防止实例被提前释放 无法回调数据)
 @param result 结果回调
 @return 返回选择器实例
 */
- (UIImagePickerController *)showImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType inViewController:(UIViewController *)viewController completion:(PandoraCameraResult)result;


@end
