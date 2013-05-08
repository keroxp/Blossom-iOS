//
//  NSString+isKana.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "NSString+isKana.h"

@implementation NSString (isKana)

- (BOOL)isKana
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    return [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"あいうえおかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢづでどなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもやゆよらりるれろわをんぁぃぅぇぉっゎゃゅょ　　"] intoString:nil];
}

- (BOOL)isLetter
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    return [scanner scanCharactersFromSet:[NSCharacterSet lowercaseLetterCharacterSet] intoString:nil];
}

- (BOOL)canTransformToSmall
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    return [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"あいうえおやゆよつわ"] intoString:nil];
}

@end