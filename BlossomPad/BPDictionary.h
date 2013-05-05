//
//  BPDictionary.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
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

@property (readonly) NSArray *entries;
@property (readonly) NSArray *headList;
@property (readonly) NSDictionary *connectionList;

@end

@interface BPDictEntry : NSObject

@property (readonly) NSString *pattern;
@property (readonly) NSString *word;
@property (readonly) NSUInteger inConnection;
@property (readonly) NSUInteger outConnection;
@property () NSUInteger pattternHeadIndex;

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
