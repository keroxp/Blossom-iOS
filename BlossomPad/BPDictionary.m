//
//  BPDictionary.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BPDictionary.h"

static BPDictionary *shared;
static NSDictionary *romakana;
static NSDictionary *smalls;

@interface BPDictionary ()
{
    NSMutableArray *_entries;
    NSMutableArray *_headList;
    NSMutableDictionary *_connectionList;
}
@end

@implementation BPDictionary

@synthesize entries = _entries;
@synthesize headList = _headList;
@synthesize connectionList = _connectionList;

+ (BPDictionary *)sharedDictionary
{
    if (!shared) {
        shared = [[BPDictionary alloc] init];        
    }
    return shared;
}

+ (NSDictionary *)sharedRomaKana
{
    return romakana;
}

+ (NSDictionary *)sharedSmalls
{
    return smalls;
}

- (id)init
{
    if (self = [super init]) {
        _entries = [NSMutableArray arrayWithCapacity:22160];
        _headList = [NSMutableArray arrayWithCapacity:10];
        _connectionList = [NSMutableDictionary dictionary];
        for (int  i = 0; i < 10; i++) {
            [_headList addObject:@[].mutableCopy];
        }
        NSString *path = nil;
        NSError *e = nil;
        // ローマ字変換テーブル
        path = [[NSBundle mainBundle] pathForResource:@"romakana" ofType:@"json"];
        NSString *romakanastr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
        romakana = [romakanastr objectFromJSONStringWithParseOptions:0 error:&e];
        // 小文字変換テーブル
        path = [[NSBundle mainBundle] pathForResource:@"smalls" ofType:@"json"];
        NSString *smallsstr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
        smalls = [smallsstr objectFromJSONStringWithParseOptions:9 error:&e];
        // 変換用辞書
        path = [[NSBundle mainBundle] pathForResource:@"dict" ofType:@"txt"];
        NSString *dictstr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
        NSArray *charsets =@[
                             [NSCharacterSet characterSetWithCharactersInString:@"あいうえおぁぃぅぇぉ"],
                             [NSCharacterSet characterSetWithCharactersInString:@"かきくけこがぎぐげご"],
                             [NSCharacterSet characterSetWithCharactersInString:@"さしすせそざじずぜぞ"],
                             [NSCharacterSet characterSetWithCharactersInString:@"たちつてとだぢづでど"],
                             [NSCharacterSet characterSetWithCharactersInString:@"なにぬねの"],
                             [NSCharacterSet characterSetWithCharactersInString:@"はひふへほばびぶべぼぱぴぷぺぽ"],
                             [NSCharacterSet characterSetWithCharactersInString:@"まみむめも"],
                             [NSCharacterSet characterSetWithCharactersInString:@"やゆよゃゅょ"],
                             [NSCharacterSet characterSetWithCharactersInString:@"らりるれろ"],
                             [NSCharacterSet characterSetWithCharactersInString:@"わをん"]
                             ];
        [dictstr enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            char h = [line characterAtIndex:0];
            if (line.length > 0 && !(h == '#' || h == ' ' || h == '\t')) {
                // 辞書エントリを作成
                NSArray *parts = [line componentsSeparatedByString:@"\t"];
                NSString *pat = [parts objectAtIndex:0];
                NSString *word = [parts objectAtIndex:1];
                NSUInteger inc = [[parts objectAtIndex:2] integerValue];
                NSUInteger outc = 0;
                if (!(parts.count < 4 || [(NSString*)[parts objectAtIndex:3] length] == 0)) {
                    outc = [[parts objectAtIndex:3] integerValue];
                }
                BPDictEntry *e = [[BPDictEntry alloc] initWithPattern:pat word:word inConnection:inc outConnection:outc];
                [_entries addObject:e];
                // 先頭読みのリストに追加
                [charsets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([word characterAtIndex:0] != '*' && [(NSCharacterSet*)obj characterIsMember:[pat characterAtIndex:0]]) {
                        e.keyIndex = idx;
                        [[_headList objectAtIndex:idx] addObject:e];
                    }
                }];
                // コネクションリストに追加
                NSMutableArray *cl = [_connectionList objectForKey:@(inc)];
                if (!cl) {
                    cl = [NSMutableArray array];
                    [_connectionList setObject:cl forKey:@(inc)];
                }
                [[_connectionList objectForKey:@(inc)] addObject:e];
            }
        }];
        if (e) {
            abort();
        }
    }
    return self;
}

@end

@implementation BPDictEntry

- (id)initWithPattern:(NSString *)pattern
                 word:(NSString *)word
         inConnection:(NSUInteger)inConnection
        outConnection:(NSUInteger)outConnection
{
    if (self = [super init]) {
        _word = word;
        _pattern = pattern;
        _inConnection = inConnection;
        _outConnection = outConnection;
    }
    return self;
}

@end