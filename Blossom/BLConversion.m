//
//  BLConversion.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/20.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLConversion.h"

static BLConversion *shared;
@implementation BLConversion

+ (BLConversion *)sharedConversion
{
    if (!shared) {
        shared = [[self alloc] init];
    }
    return shared;
}

- (void)convertGroupedParagraph:(NSString *)paragraph complete:(BLConversionCompleteBlock)complete
{
    
}
@end
