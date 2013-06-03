//
//  BLDictEntry.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/26.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLDictEntry.h"
#import "BLDictionary.h"

@interface NSArray (Join)

- (NSString*)joinStrings;

@end

@implementation NSArray (Join)

- (NSString *)joinStrings
{
    NSMutableString *ms = @"".mutableCopy;
    for (id obj in self) {
        if ([obj isKindOfClass:[NSString class]]) {
            [ms appendString:obj];
        }
    }
    return ms;
}

@end

@interface BLDictEntry ()
{
    // 深さ優先探索に使うスタック
    NSMutableArray *_depthStack;
    // 現在接続が確認されているエントリのスタック
    NSMutableArray *_entryStack;
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
        _depthStack = [NSMutableArray array];
        _entryStack = [NSMutableArray array];
    }
    return self;
}

- (void)_searchForConnections
{
    
}

- (void)__searchForConnectionsOnFround:(void (^)(NSString *))found complete:(void (^)(NSUInteger))complete
{
    NSMutableArray *connected = @[].mutableCopy;
    NSUInteger total = 0;
    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"*"];
    BLDictEntry *previousEntry = nil;
    // ルートエントリを自身に設定
    [self pushToStack:self];
    // スタックが空になるまで深さ優先探索する
    while (_depthStack.count != 0) {
        // スタックからエントリを取り出す
        BLDictEntry *i = [self popFromStack];
        if (i.depthInConnection < previousEntry.depthInConnection) {
            // バックしたら接続を一段階遡る
            [connected removeLastObject];
        }
        // iが後方接続可能進んだら接続を追加
        if (i.depthInConnection > previousEntry.depthInConnection) {
            [connected addObject:previousEntry.word];
        }
        if (i.outConnection) {
            // エントリが後方接続可能ならさらに探索
            for (BLDictEntry *j in [i connections]) {
                j.depthInConnection = i.depthInConnection + 1;
                [self pushToStack:j];
            }
        }else{
            // 最下層に来たらコールバックに投げる
            if (found) {
                NSString *c = [[connected joinStrings] stringByAppendingString:i.word];
                found(c);
            }
            total++;
        }
        // 前のエントリを保存
        previousEntry = i;
    }
    if (complete){
        complete(total);
    }
}

- (NSArray*)connections
{
    if (self.outConnection) {
        return [[[BLDictionary sharedDictionary] connectionList] objectForKey:@(self.outConnection)];
    }
    return nil;
}

- (BLDictEntry*)popFromStack
{
    if (_depthStack.count == 0) {
        NSLog(@"stack is empty");
        abort();
    }else{
        BLDictEntry *e = [_depthStack lastObject];
        [_depthStack removeLastObject];
        return e;
    }
}

- (void)pushToStack:(BLDictEntry*)entry
{
    [_depthStack addObject:entry];
}

@end    