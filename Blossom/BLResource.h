//
//  BLResource.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/20.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

/* 
 Blossomで使用するリソースを一括して管理するクラス
 */

#import <Foundation/Foundation.h>
#import "BLDictionary.h"

@interface BLResource : NSObject

+ (NSDictionary*)sharedRomaKana;
+ (NSDictionary*)sharedSmalls;

@end
