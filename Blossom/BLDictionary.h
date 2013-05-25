//
//  BPDictionary.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

/* 
 アプリケーションで共通で使用するリソースを管理するクラス
 */

#import <Foundation/Foundation.h>

@class BLDictEntry;

typedef void (^BLSearchFoundBlock)(NSString *pattern, BLDictEntry *entry);
typedef void (^BLSearchCompleteBlock)(NSString *pattern, NSArray *candidates);

typedef enum{
    BPDictionarySearchOptionNone = 0,
    BPDictionarySearchOptionOrderedSame,
    BPDictionarySearchOptionContains,
    BPDictionarySearchOptionT9
}BLDictionarySearchOption;

@interface BLDictionary : NSObject

/* Shared Instance */
+ (BLDictionary*)sharedDictionary;

/* 全辞書エントリのリスト */
@property (readonly) NSArray *entries;
/* 先頭読みが同じ行に所属するエントリのリスト */
@property (readonly) NSArray *headList;
/* 前方接続が同じエントリのリスト */
@property (readonly) NSDictionary *connectionList;
/* 新規検索 */
- (void)searchForEntriesWithPattern:(NSString*)pattern
                              found:(BLSearchFoundBlock)found
                           complete:(BLSearchCompleteBlock)complete;

@end

@interface BLDictEntry : NSObject

/* 読み */
@property (readonly) NSString *pattern;
/* 文字 */
@property (readonly) NSString *word;
/* 前方接続の番号 */
@property (readonly) NSUInteger inConnection;
/* 後方接続の番号 */
@property (readonly) NSUInteger outConnection;
/* リンクリストのインデックス */
@property (readonly) NSUInteger connectionLinkIndex;
/* 先頭読みリストのインデックス*/
@property (readonly) NSUInteger keyLinkIndex;
/* 読みの先頭が何処の行に所属するか */
@property () NSUInteger keyIndex;

/* イニシャライザ */
- (id)initWithPattern:(NSString*)pattern
                 word:(NSString*)word
         inConnection:(NSUInteger)inConnection
        outConnection:(NSUInteger)outConnection;

@end
