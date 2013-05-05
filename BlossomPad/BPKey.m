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
#define kKeyWidth 82.0f
#define kKeyHeight 74.0f
#define kRow2MarginLeft 40.0f
#define kKeyMarginRight 10.0f
#define kKeyMarginUp 8.0f

@implementation BPKey

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
        _keyWidth = (w) ? w : kKeyWidth;
        _keyHeight = (h) ? h : kKeyHeight;
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

- (void)needsLayoutForOrientation:(UIDeviceOrientation)orientation
{
    if (orientation == UIDeviceOrientationUnknown) {
        orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    NSUInteger i = self.indexPath.section;
    NSUInteger j = self.indexPath.row;
    CGRect f = CGRectZero;
    CGFloat x,y,w,h;
    x = (kKeyWidth + kKeyMarginRight)*j + kKeyMarginRight;
    y = (kKeyHeight + kKeyMarginUp)*i + kKeyMarginUp;
    w = _keyWidth;
    h = _keyHeight;
    if (UIDeviceOrientationIsPortrait(orientation)){
        // たて        
        [self.titleLabel setFont:[UIFont systemFontOfSize:20]];
        f = CGRectMake(x*3/4, y*3/4, w*3/4, h*3/4);
        // ２段目をずらす
        if (i == 1) f = CGRectMake(kRow2MarginLeft+x*3/4,y*3/4,w*3/4,h*3/4);
    }else{
        [self.titleLabel setFont:[UIFont systemFontOfSize:25]];
        f = CGRectMake(x, y, w, h);
        // ２段目をずらす
        if (i == 1) f = CGRectMake(kRow2MarginLeft+x,y,w,h);
    }
    [self setFrame:f];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
}

@end
