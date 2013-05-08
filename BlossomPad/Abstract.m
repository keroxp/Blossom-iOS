//
//  Abstract.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "Abstract.h"


@implementation Abstract

@dynamic created;
@dynamic updated;
@dynamic identifier;

+ (id)createEntity
{
    Abstract *a = [super createEntity];
    NSDate *d =  [NSDate date];
    a.created = d;
    a.updated = d;
    a.identifier = [d description];
    return a;
}


@end
