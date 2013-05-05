//
//  BPDictionary.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    BPDictionarySearchOptionNone = 0,
    BPDictionarySearchOptionOrderedSame,
    BPDictionarySearchOptionContains,
    BPDictionarySearchOptionT9
}BPDictionarySearchOption;

@interface BPDictionary : NSObject

+ (BPDictionary*)sharedDictionary;
+ (NSDictionary*)sharedRomaKana;
+ (NSDictionary*)sharedSmalls;

@property (readonly) NSArray *entries;
@property (readonly) NSArray *headList;
@property (readonly) NSDictionary *connectionList;

@end

@interface BPDictEntry : NSObject

/* 読み */
@property (readonly) NSString *pattern;
/* 文字 */
@property (readonly) NSString *word;
@property (readonly) NSUInteger inConnection;
@property (readonly) NSUInteger outConnection;
/* リンクリストのインデックス */
@property (readonly) NSUInteger connectionLinkIndex;
/* 先頭読みリストのインデックス*/
@property (readonly) NSUInteger keyLinkIndex;
/* 読みの先頭が何処の行に所属するか */
@property () NSUInteger keyIndex;

- (id)initWithPattern:(NSString*)pattern
                 word:(NSString*)word
         inConnection:(NSUInteger)inConnection
        outConnection:(NSUInteger)outConnection;

- (void)searchForEntryForPattern:(NSString*)pattern
                            word:(NSString*)word
                          option:(BPDictionarySearchOption)option
                        progress:(void (^)(BPDictEntry* entry))progress
                          finish:(void (^)(BOOL found))finish;

@end
