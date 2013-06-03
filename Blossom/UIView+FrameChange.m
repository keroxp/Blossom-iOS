//
//  UIView+FrameChange.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/28.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "UIView+FrameChange.h"
#define NIL -9999999999

@implementation UIView (FrameChange)

- (void)_setX:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h
{
    CGRect f = self.frame;
    if (x != NIL) f.origin.x = x;
    if (y != NIL) f.origin.y = y;
    if (w != NIL) f.size.width = w;
    if (h != NIL) f.size.height = h;
    self.frame = f;
}

- (void)setOrigin:(CGPoint)origin
{
    [self _setX:origin.x y:origin.y w:NIL h:NIL];
}

- (void)setSize:(CGSize)size
{
    [self _setX:NIL y:NIL w:size.width h:size.height];
}

- (void)setX:(CGFloat)x
{
    [self _setX:x y:NIL w:NIL h:NIL];
}

- (void)setY:(CGFloat)y
{
    [self _setX:NIL y:y w:NIL h:NIL];
}

- (void)setWidth:(CGFloat)w
{
    [self _setX:NIL y:NIL w:w h:NIL];
}

- (void)setHeight:(CGFloat)h
{
    [self _setX:NIL y:NIL w:NIL h:h];
}

@end
