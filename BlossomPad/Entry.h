//
//  Entry.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/06.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Abstract.h"


@interface Entry : Abstract

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;

@end
