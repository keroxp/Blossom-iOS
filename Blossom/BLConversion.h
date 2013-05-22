//
//  BLConversion.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/20.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDictionary.h"

typedef void (^BLConversionCompleteBlock)(NSString *pattern, NSArray *candidates);

@interface BLConversion : NSObject

+ (BLConversion*)sharedConversion;

- (void)convertGroupedParagraph:(NSString*)paragraph
                       complete:(BLConversionCompleteBlock)complete;

@end
