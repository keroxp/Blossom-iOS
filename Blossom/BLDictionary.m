//
//  BPDictionary.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLDictionary.h"

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
    BLSearchNotFoundBlock _notFoundBlock;
    NSOperation *_currentOperation;
    NSOperationQueue *_operationQueue;
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
        _operationQueue = [[NSOperationQueue alloc] init];
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
                           notFound:(BLSearchNotFoundBlock)notFound
{
    if (pattern.length == 0) {
        return;
    }
    _currentPattern = pattern;
    _foundBlock = found;
    _notFoundBlock = notFound;
    // 検索を止める
    if ([_operationQueue operationCount] > 0) {
        [_operationQueue cancelAllOperations];
    }
    // デフォルトの検索はすべてで、以後の検索はマッチしたものに限る
    NSArray *array = nil;
    __block NSString *__pattern = pattern;
    if (pattern.length == 1) {
        array = [_headList objectAtIndex:[self headIndexWithPattern:pattern]];
    }else{
        if (_candidates.count > 0) {
            array = [_candidates mutableCopy];
            [_candidates removeAllObjects];
        }
    }
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    [_operationQueue addOperationWithBlock:^{
        NSString *regexp = [NSString stringWithFormat:@"^%@.*?$",pattern];
        // 走査
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            // 検索
            BLDictEntry *e = (BLDictEntry*)obj;
            NSRange r = [e.pattern rangeOfRegex:regexp];
            BOOL complete = (idx == array.count - 1) ? YES : NO;
            // 見つかったら
            if (r.location != NSNotFound) {
                dispatch_async(main_queue, ^{
                    found(pattern, e, complete, stop);
                });
                [_candidates addObject:e];
            }
            // 終了して見つからなかったら
            if (complete && _candidates.count == 0){
                dispatch_async(main_queue, ^{
                    notFound(pattern);
                });
            }
        }];
    }];
}

- (void)cancelSearch
{
    [_operationQueue cancelAllOperations];
    [_candidates removeAllObjects];
}

@end

@implementation BLDictEntry

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