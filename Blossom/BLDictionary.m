//
//  BPDictionary.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLDictionary.h"
#import "BLDictEntry.h"

static BLDictionary *shared;

@interface BLDictionary ()
{
    NSMutableArray *_entries;
    NSMutableArray *_headList;
    NSMutableDictionary *_connectionList;
    NSArray *_headCharactersets;
    NSString *_currentPattern;
    NSMutableArray *_candidates;
    BLSearchFoundBlock _foundBlock;
    BLSearchCompleteBlock _completeBlock;
}
@end

@implementation BLDictionary

@synthesize entries = _entries;
@synthesize headList = _headList;
@synthesize connectionList = _connectionList;

+ (BLDictionary *)sharedDictionary
{
    if (!shared) {
        shared = [[BLDictionary alloc] init];
    }
    return shared;
}

- (id)init
{
    if (self = [super init]) {
        _entries = [NSMutableArray arrayWithCapacity:22160];
        _candidates = [NSMutableArray arrayWithCapacity:22160];
        _headList = [NSMutableArray arrayWithCapacity:10];
        _connectionList = [NSMutableDictionary dictionary];
        for (int  i = 0; i < 10; i++) {
            [_headList addObject:@[].mutableCopy];
        }
        _headCharactersets = @[
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
        NSString *path = nil;
        NSError *e = nil;
        // 変換用辞書
        path = [[NSBundle mainBundle] pathForResource:@"dict" ofType:@"txt"];
        NSString *dictstr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
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
                BLDictEntry *e = [[BLDictEntry alloc] initWithPattern:pat word:word inConnection:inc outConnection:outc];
                [_entries addObject:e];
                // 先頭読みのリストに追加
                [_headCharactersets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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

/* 
 static String patInit(String pat, int level){
    String p = "";
    String top = "";
    Pattern re;
    Matcher m;
    
    cslength[level] = 0;
    if(pat.length() > 0){
        re = Pattern.compile("^(\\[[^\\]]+\\])(.*)$");
        m = re.matcher(pat);
        if(m.find()){
            top = m.group(1);
            p = patInit(m.group(2),level+1);
        }else {
            re = Pattern.compile("^(.)(.*)$");
            m = re.matcher(pat);
            m.find();
            top = m.group(1);
            p = patInit(m.group(2),level+1);
        }
        cslength[level] = cslength[level+1]+1;
    } 
    top += (p.length() > 0 ? "("+p+")?" : "");
    regexp[level] = Pattern.compile("^("+top+")");
    return top;
 }
 */

- (NSUInteger)headIndexWithPattern:(NSString*)pattern
{
    for (NSCharacterSet *set in _headCharactersets) {
        if ([set characterIsMember:[pattern characterAtIndex:0]]) {
            return [_headCharactersets indexOfObject:set];
        }
    }
    return -1;
}

- (void)searchForEntriesWithPattern:(NSString *)pattern
                              found:(BLSearchFoundBlock)found
                           complete:(BLSearchCompleteBlock)complete

{
    if (pattern.length == 0) {
        return;
    }
    _currentPattern = pattern;
    _foundBlock = [found copy];
    _completeBlock = [complete copy];

    NSArray *array = nil;
    if (pattern.length == 1) {
        // 最初の一文字の検索のみ、平仮名の行で振り分ける
        array = [_headList objectAtIndex:[self headIndexWithPattern:pattern]];
    }else{
        // 以降はそれ以前の検索で見つかった結果から探す
        if (_candidates.count > 0) {
            array = [_candidates mutableCopy];
            [_candidates removeAllObjects];
        }else{
            // ここには来ないはず
            NSAssert(NO, nil);
        }
    }
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_queue_t async_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(async_queue, ^{
        NSString *regexp = [NSString stringWithFormat:@"^%@.*?$",pattern];
        // 走査
        for (BLDictEntry *e in array) {
            // 検索
            NSRange r = [e.pattern rangeOfRegex:regexp];
            // 見つかったら
            if (r.location != NSNotFound) {
                // 接続辞書を検索
                if (e.outConnection) {
//                    [e searchForConnectionsOnFround:^(NSString *connected) {
//                        NSLog(@"%@",connected);
//                    } complete:^(NSUInteger total) {
//                        NSLog(@"%d connection found for : %@",total,e.word);
//                    }];
                }
                if (found) {
                    dispatch_async(main_queue, ^{
                        found(pattern,e);
                    });
                }
                [_candidates addObject:e];
            }
        }
        // 終了して見つからなかったら
        if (complete) {
            NSLog(@"%i entries found for %@",_candidates.count,pattern);
            dispatch_async(main_queue, ^{
                complete(pattern, [_candidates copy]);
            });
        }
    });
}


@end

