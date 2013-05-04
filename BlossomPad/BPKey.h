//
//  BPKey.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BPKey : UIButton

/* アイコン（optional） */
@property (nonatomic) UIImage *icon;
/*  */
@property (nonatomic) NSString *keystr;
/* ピース */
@property (nonatomic) NSArray *pieces;
/* モディファイアか */
@property (nonatomic, readonly) BOOL isModifier;
/* 繰り返し可能なキーか */
@property (readonly) BOOL isRepeatable;
/* トグル可能なキーか */
@property (readonly) BOOL isStickey;
/* スライドUIが使えるキーか */
@property (readonly) BOOL isTrigger;
/* 幅 */
@property (readonly) CGFloat keyWidth;
/* 高さ */
@property (readonly) CGFloat keyHeight;
/*  */
@property (readonly) NSIndexPath *indexPath;

/* コンストラクタ */
- (id)initWithJSON:(NSDictionary*)JSON line:(NSUInteger)line index:(NSUInteger)index;

@end
