//
//  BPKey.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import "BPKey.h"
#define kDefaultFrame CGRectMake(0,0,82,74)
#define kLeftMargin 10.0f

@implementation BPKey

- (id)initWithJSON:(NSDictionary *)JSON line:(NSUInteger)line index:(NSUInteger)index
{
    CGFloat w = ([[JSON objectForKey:@"width"] floatValue]);
    CGFloat h = ([[JSON objectForKey:@"height"] floatValue]);
    CGRect f = kDefaultFrame;
    if (w) {
        f.size.width = w;
    }
    if (h) {
        f.size.height = h;
    }
    if (self = [super initWithFrame:f]) {
        _icon = [UIImage imageNamed:[self objectForKey:@"icon" ofJSON:JSON]];
        _isTrigger = [[self objectForKey:@"isTrigger" ofJSON:JSON] boolValue];
        _isRepeatable = [[self objectForKey:@"isRepeatable" ofJSON:JSON] boolValue];
        _isStickey = [[self objectForKey:@"isStickey" ofJSON:JSON] boolValue];
        _isModifier = [[self objectForKey:@"isModifier" ofJSON:JSON] boolValue];
        _keystr = [self objectForKey:@"key" ofJSON:JSON];
        _pieces = [self objectForKey:@"pieces" ofJSON:JSON];
        _keyWidth = w;
        _keyHeight = h;
        _indexPath = [NSIndexPath indexPathForRow:index inSection:line];
        // 背景
        [self setBackgroundImage:[UIImage imageNamed:@"keybg"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:(float)1.0f
                                            green:(float)164.0f/255.0f
                                             blue:(float)164.0f/255.0f
                                            alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
        // タイトルもしくはアイコンを設定
        if (!_icon) {
            [self setTitle:[_keystr uppercaseString] forState:UIControlStateNormal];
        }else{
            UIImageView *iv = [[UIImageView alloc] initWithImage:_icon];
            iv.center = self.center;
            [self addSubview:iv];
        }
    }
    return self;
}

- (id)objectForKey:(NSString*)key ofJSON:(NSDictionary*)JSON
{
    return ([JSON objectForKey:key]) ? [JSON objectForKey:key] : nil;
}

- (void)setTouchesBeganBlock:(BPKeyTouchHandlingBlock)began
           touchesMovedBlock:(BPKeyTouchHandlingBlock)moved
           touchesEndedBlock:(BPKeyTouchHandlingBlock)ended
{
    _touchesBeganBlock = began;
    _touchesMovedBlock = moved;
    _touchesEndedBlock = ended;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchesBeganBlock) self.touchesBeganBlock(self,touches,event);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchesMovedBlock) self.touchesMovedBlock(self,touches,event);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchesMovedBlock) self.touchesEndedBlock(self,touches,event);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
