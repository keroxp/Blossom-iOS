//
//  BPCandidateCell.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BPCandidateCell.h"

@implementation BPCandidateCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [_textLabel setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"candidatebg"]]];
        [self.contentView addSubview:_textLabel];
        UIImageView *iv =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"candidateseparator"]];
        CGRect f = CGRectMake(CGRectGetWidth(self.bounds)-1, 0, 1, CGRectGetHeight(self.bounds));
        [iv setFrame:f];
        [self.contentView addSubview:iv];
        
    }
    return self;
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
