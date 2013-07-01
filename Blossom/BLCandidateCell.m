//
//  BPCandidateCell.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLCandidateCell.h"

@implementation BLCandidateCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"candidatebgselected"]]];
    }else{
        [self setBackgroundColor:[UIColor clearColor]];
    }
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
