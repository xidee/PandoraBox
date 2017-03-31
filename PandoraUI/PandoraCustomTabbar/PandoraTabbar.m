//
//  PandoraTabbar.m
//  PandoraBox
//
//  Created by xidee on 2017/3/28.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraTabbar.h"

@interface PandoraTabbar ()

//用来记录上次选中的下标
@property (nonatomic,assign) NSInteger lastSelectIndex;

@end

@implementation PandoraTabbar

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(self.backgroundImage)
    {
        self.backgroundColor = [UIColor colorWithPatternImage:self.backgroundImage];
    }
}

- (void)setItems:(NSArray<PandoraTabbarItem *> *)items
{
    _items = items;
    
    CGFloat width = self.bounds.size.width / items.count;
    CGFloat height = self.bounds.size.height;
    
    for (int i = 0; i < items.count; i ++) {
        PandoraTabbarItem *item = [items objectAtIndex:i];
        if (i == 0) {
            item.selected = YES;
            self.lastSelectIndex = 0;
        }
        item.frame = CGRectMake(i * width, 0, width, height);
        [item addTarget:self action:@selector(tabBarSelectItem:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:item];
    }
}

- (void)tabBarSelectItem:(PandoraTabbarItem *)item
{
    NSInteger index = [self.items indexOfObject:item];
    if (index != self.lastSelectIndex) {
        PandoraTabbarItem *lastItem = [self.items objectAtIndex:self.lastSelectIndex];
        lastItem.selected = NO;
        item.selected = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarDidSelectedItemAtIndex:)]) {
            [self.delegate tabBarDidSelectedItemAtIndex:index];
        }
        self.lastSelectIndex = index;
    }
}

@end
