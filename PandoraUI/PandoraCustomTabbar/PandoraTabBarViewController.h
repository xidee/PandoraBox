//
//  PandoraTabBarViewController.h
//  PandoraBox
//
//  Created by xidee on 2017/3/9.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  动态TabBar控制器

#import <UIKit/UIKit.h>
#import "PandoraTabbar.h"

@interface PandoraTabBarViewController : UITabBarController

/**
    tabbar控制器
 */
@property (nonatomic ,strong) PandoraTabbar *customTabbar;

@end


