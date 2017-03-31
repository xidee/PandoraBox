//
//  PandoraTabbar.h
//  PandoraBox
//
//  Created by xidee on 2017/3/28.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PandoraTabbarItem.h"

@protocol PandoraTabBarDelegate <NSObject>

- (void)tabBarDidSelectedItemAtIndex:(NSInteger)index;

@end

@interface PandoraTabbar : UIView

@property (nonatomic ,strong) NSArray <PandoraTabbarItem *> *items;
@property (nonatomic ,strong) UIImage *backgroundImage;

@property (nonatomic ,weak) id <PandoraTabBarDelegate>delegate;

- (void)tabBarSelectItem:(PandoraTabbarItem *)item;

@end
