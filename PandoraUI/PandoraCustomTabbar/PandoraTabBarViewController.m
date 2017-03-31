//
//  PandoraTabBarViewController.m
//  PandoraBox
//
//  Created by xidee on 2017/3/9.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraTabBarViewController.h"

@interface PandoraTabBarViewController ()<UITabBarControllerDelegate>

@end

@implementation PandoraTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //创建自定义的tabbar
    self.customTabbar = [[PandoraTabbar alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.tabBar.bounds.size.height)];
    self.delegate = self;
    [self.tabBar addSubview:self.customTabbar];
    self.tabBar.hidden = NO;
}

- (void)viewWillLayoutSubviews
{
    //清空tabBar原有的title
    for (UITabBarItem *item in self.tabBar.items) {
        item.title = @"";
    }
}

#pragma mark - PandoraTabBarDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    [self.customTabbar tabBarSelectItem:[self.customTabbar.items objectAtIndex:index]];
}


@end


