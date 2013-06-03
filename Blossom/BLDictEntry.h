//
//  BLDictEntry.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/26.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BLDictEntry : NSObject

/* 読み */
@property (readonly) NSString *pattern;
/* 文字 */
@property (readonly) NSString *word;
/* 前方接続の番号 */
@property (readonly) NSUInteger inConnection;
/* 後方接続の番号 */
@property (readonly) NSUInteger outConnection;
/* 読みの先頭が何処の行に所属するか */
@property () NSUInteger keyIndex;
/* 接続リンクを探索するときに自身がいま何階層目にいるかを表す */
@property (assign) NSUInteger depthInConnection;

/* イニシャライザ */
- (id)initWithPattern:(NSString*)pattern
                 word:(NSString*)word
         inConnection:(NSUInteger)inConnection
        outConnection:(NSUInteger)outConnection;

/* 自身の接続を深さ優先探索する */
- (void)searchForConnectionsOnFround:(void(^)(NSString *connected))found
                            complete:(void(^)(NSUInteger total))complete;

@end
