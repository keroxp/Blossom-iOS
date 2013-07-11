//
//  BPKey.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import "BLKey.h"
#import "BLKeyboard.h"
#define kDefaultFrame CGRectMake(0,0,82,74)
#define kLeftMargin 10.0f


@implementation BLKey

- (id)initWithJSON:(NSDictionary *)JSON line:(NSUInteger)line index:(NSUInteger)index
{
    CGFloat w = (float)([[JSON objectForKey:@"width"] floatValue]);
    CGFloat h = (float)([[JSON objectForKey:@"height"] floatValue]);
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
        _isFunctional = [[self objectForKey:@"isFunctional" ofJSON:JSON] boolValue];
        _keystr = [self objectForKey:@"key" ofJSON:JSON];
        _pieces = [self objectForKey:@"pieces" ofJSON:JSON];
        _keylabel = [self objectForKey:@"label" ofJSON:JSON];
        _kanaKeyLabel = [self objectForKey:@"kanaLabel" ofJSON:JSON];
        _keyWidth = (w) ? w : 82;
        _keyHeight = (h) ? h : 74;
        _indexPath = [NSIndexPath indexPathForRow:index inSection:line];
        // 背景
        UIImage *i = [UIImage imageNamed:@"keybg"];
        [self setBackgroundImage:[i stretchableImageWithLeftCapWidth:15.0f topCapHeight:15.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setShadowOffset:CGSizeMake(0, 2)];
        [self.titleLabel setFont:[UIFont systemFontOfSize:25]];
        // タイトルもしくはアイコンを設定
        if (!_icon) {
            [self setTitle:[[self keylabel] uppercaseString] forState:UIControlStateNormal];
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

- (NSString *)keylabel
{
    return (_keylabel) ? _keylabel : _keystr;
}

- (NSString *)kanaKeyLabel
{
    return (_kanaKeyLabel) ? _kanaKeyLabel : self.keylabel;
}

- (void)setLabelForMode:(NSInteger)mode
{
    BLInputMode im = mode;
    switch (im) {
        case BLInputModeAlphabet:
            [self setTitle:self.keylabel forState:UIControlStateNormal];
            break;
        case BLInputModeRomaKana:
            [self setTitle:self.kanaKeyLabel forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)setTouchesBeganBlock:(BLKeyTouchHandlingBlock)began
           touchesMovedBlock:(BLKeyTouchHandlingBlock)moved
           touchesEndedBlock:(BLKeyTouchHandlingBlock)ended
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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
}

@end
