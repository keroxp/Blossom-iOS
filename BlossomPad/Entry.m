//
//  Entry.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/06.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "Entry.h"


@implementation Entry

@dynamic text;
@dynamic title;

+ (id)createEntity
{
    Entry *e = [super createEntity];
    e.title = @"名称未設定のエントリ";
    return e;
}
@end
