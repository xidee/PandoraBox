//
//  PandoraTabbarItem.h
//  PandoraBox
//
//  Created by xidee on 2017/3/24.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  全定制化的tabbarItem

#import <UIKit/UIKit.h>

@interface PandoraTabbarItem : UIControl

/**
    选项卡标题
 */
@property (nonatomic ,copy) NSString *title;
/**
    未选中title文本样式 (默认字号12 黑色)
 */
@property (nonatomic ,strong) NSDictionary *unselectedTitleAttributes;
/**
    选中的title文本样式 (默认字号12 黑色)
 */
@property (nonatomic ,strong) NSDictionary *selectedTitleAttributes;
/**
    未选中图片样式
 */
@property (nonatomic ,strong) UIImage *unselectedImage;
/**
    选中图片样式
 */
@property (nonatomic ,strong) UIImage *selectedImage;
/**
    右上角标记文本
 */
@property (nonatomic ,copy) NSString *badgeValue;
/**
    标记字体大小  (默认12)
 */
@property (nonatomic ,strong) UIFont *badgeFont;
/**
    标记文本色 （默认白色）
 */
@property (nonatomic ,strong) UIColor *badgeTitleColor;
/**
    标记背景色 (默认红色)
 */
@property (nonatomic ,strong) UIColor *badgeBackgroundColor;

@end
