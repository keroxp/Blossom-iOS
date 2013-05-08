//
//  NSString+isKana.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (isKana)

- (BOOL)isKana;
- (BOOL)isLetter;
- (BOOL)canTransformToSmall;

@end