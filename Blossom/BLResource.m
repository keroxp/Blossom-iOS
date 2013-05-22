//
//  BLResource.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/20.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLResource.h"

static NSDictionary *romakana;
static NSDictionary *smalls;

@implementation BLResource

+ (NSString*)resourceAtPath:(NSString*)path ofType:(NSString*)type
{
    NSError *e = nil;
    NSString *p = [[NSBundle mainBundle] pathForResource:path ofType:type];
    NSString *d = [[NSString alloc] initWithContentsOfFile:p encoding:NSUTF8StringEncoding error:&e];
    if (e) {
        abort();
    }
    return d;
}

+ (NSDictionary *)sharedRomaKana
{
    if (!romakana) {
        // ローマ字変換テーブル
        romakana = [[self resourceAtPath:@"romakana" ofType:@"json"] objectFromJSONString];
    }
    return romakana;
}

+ (NSDictionary *)sharedSmalls
{
    if (!smalls) {
        // 小文字変換テーブル
        smalls = [[self resourceAtPath:@"smalls" ofType:@"json"] objectFromJSONString];
    }
    return smalls;
}

@end
