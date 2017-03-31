//
//  PandoraTabbarItem.m
//  PandoraBox
//
//  Created by xidee on 2017/3/24.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraTabbarItem.h"

@implementation PandoraTabbarItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInitialization];
    }
    return self;
}

/**
    初始化一些默认配置
 */
- (void)defaultInitialization
{
    self.backgroundColor = [UIColor clearColor];
    self.title = @"";
    self.unselectedTitleAttributes = @{
                                       NSFontAttributeName:[UIFont systemFontOfSize:12],
                                       NSForegroundColorAttributeName: [UIColor blackColor]
                                       };
    self.selectedTitleAttributes = @{
                                       NSFontAttributeName:[UIFont systemFontOfSize:12],
                                       NSForegroundColorAttributeName: [UIColor blackColor]
                                       };
    self.badgeBackgroundColor = [UIColor redColor];
    self.badgeTitleColor = [UIColor whiteColor];
    self.badgeFont = [UIFont systemFontOfSize:12];
}

/**
    重写绘制方法 绘制内容
 */
- (void)drawRect:(CGRect)rect
{
    UIImage *image = self.isSelected ? self.selectedImage : self.unselectedImage;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    //绘制图片
    [image drawInRect:CGRectMake(self.frame.size.width / 2.f - image.size.width / 2.f, self.frame.size.height / 2.f - image.size.height / 2.0, image.size.width, image.size.height)];
    if (self.title.length) {
        //绘制标题
        NSDictionary *titleAttributes = self.isSelected ? self.selectedTitleAttributes : self.unselectedTitleAttributes;
        CGSize titleSize = [self.title boundingRectWithSize:CGSizeMake(self.frame.size.width, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:titleAttributes context:nil].size;
        
        CGContextSetFillColorWithColor(context, [titleAttributes [NSForegroundColorAttributeName] CGColor]);
        [self.title drawInRect:CGRectMake(self.frame.size.width / 2.f - titleSize.width / 2.f,self.frame.size.height - titleSize.height,titleSize.width, titleSize.height) withAttributes:titleAttributes];
    }
    
    //绘制提醒标识符
    if (self.badgeValue.length) {
        CGSize badgeSize =[self.badgeValue boundingRectWithSize:CGSizeMake(self.frame.size.width, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.badgeFont} context:nil].size;
        //绘制标示符背景
        if (badgeSize.width < badgeSize.height) {
            badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
        }
        CGRect badgeBackgroundFrame = CGRectMake(self.frame.size.width / 2.f + image.size.width / 2.f, 2, badgeSize.width + 4, badgeSize.height + 4);
        CGContextSetFillColorWithColor(context, self.badgeBackgroundColor.CGColor);
        CGContextFillEllipseInRect(context, badgeBackgroundFrame);
        //绘制标示符
        CGContextSetFillColorWithColor(context, self.badgeTitleColor.CGColor);
        
        NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [badgeTextStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [badgeTextStyle setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *badgeTextAttributes = @{
                                              NSFontAttributeName: self.badgeFont,
                                              NSForegroundColorAttributeName: self.badgeTitleColor,
                                              NSParagraphStyleAttributeName: badgeTextStyle,
                                              };
        
        [self.badgeValue drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame) + 2,
                                                 CGRectGetMinY(badgeBackgroundFrame) + 2,
                                                 badgeSize.width, badgeSize.height)
                       withAttributes:badgeTextAttributes];
    }
    
    CGContextRestoreGState(context);
}

- (void)setBadgeValue:(NSString *)badgeValue
{   //标识值改变时候重新绘制
    _badgeValue = badgeValue;
    [self setNeedsDisplay];
}

@end
