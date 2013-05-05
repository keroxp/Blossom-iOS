//
//  BPPieView.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BPPieView.h"

#define kDefaultPieFrame CGRectMake(0,0,200,200)

static BPPieView *shared;
@implementation BPPieView

+ (BPPieView *)sharedView
{
    if (!shared) {
        shared = [[self alloc] initWithFrame:kDefaultPieFrame];
    }
    return shared;
}

+ (void)showInView:(UIView *)view atPoint:(CGPoint)point centerChar:(NSString *)centerChar pieces:(NSArray *)pieces
{
    BPPieView *s = [self sharedView];
    [s removeFromSuperview];
    [s setCenter:point];
    [s setCenterChar:centerChar pieces:pieces];
    // ここでなんかアニメとかいれる？
    [view addSubview:s];
    [s setIsShowing:YES];
}

+ (void)hide
{
    [[self sharedView] removeFromSuperview];
    [[self sharedView] setIsShowing:NO];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect a = CGRectMake(75, 20, 50, 50);
        CGRect i = CGRectMake(130, 62, 50, 50);
        CGRect u = CGRectMake(112, 130, 50, 50);
        CGRect e = CGRectMake(38, 130, 50, 50);
        CGRect o = CGRectMake(20, 62, 50, 50);
        CGRect frames [5] = {a,i,u,e,o};
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"piebg"]]];
        
        NSMutableArray *ma = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 5 ; i++) {
            UIButton *p = [[UIButton alloc] initWithFrame:frames[i]];
            [p.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            [p setBackgroundImage:[UIImage imageNamed:@"piepiecebg"] forState:UIControlStateHighlighted];
            [ma addObject:p];
            [self addSubview:p];
        }
        _piePieces = ma;
    }
    return self;
}

- (void)setCenterChar:(NSString *)centerChar pieces:(NSArray *)pieces
{
    if (centerChar != _centerChar && pieces != _pieces) {
        _centerChar = centerChar;
        _pieces = pieces;
        // 文字列を入れ替え
        for (int i = 0, max = pieces.count ; i < max; i++) {
            UIButton *pie = [_piePieces objectAtIndex:i];
            NSString *s = [pieces objectAtIndex:i];
            [pie setTitle:s forState:UIControlStateNormal];
        }
    }
}

- (void)setHighlited:(BOOL)highlited atIndex:(NSUInteger)index
{
    UIButton *b = [_piePieces objectAtIndex:index];
    [b setHighlighted:highlited];
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
