//
//  UIView+FrameChange.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/28.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameChange)

- (void)setOrigin:(CGPoint)origin;
- (void)setSize:(CGSize)size;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setWidth:(CGFloat)w;
- (void)setHeight:(CGFloat)h;

@end
