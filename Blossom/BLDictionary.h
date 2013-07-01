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
/* 変換 */
- (void)convertText:(NSString*)text
            success:(void (^)(id candidates))success
            failure:(void (^)(NSError* e))failure;

@end
