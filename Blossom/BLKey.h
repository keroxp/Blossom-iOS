//
//  BPKey.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>

@class  BLKey;
typedef void (^BLKeyTouchHandlingBlock)(BLKey* key, NSSet *touches, UIEvent* event);

@interface BLKey : UIButton

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
/* アイコン（optional） */
@property (nonatomic) UIImage *icon;
/*  */
@property (nonatomic) NSString *keystr;
/*  */
@property (nonatomic) NSString *keylabel;
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
/* */
@property (readonly) BOOL isFunctional;
/* 幅 */
@property (readonly) CGFloat keyWidth;
/* 高さ */
@property (readonly) CGFloat keyHeight;
/*  */
@property (readonly) NSIndexPath *indexPath;
@property (nonatomic,copy) BLKeyTouchHandlingBlock touchesBeganBlock;
@property (nonatomic,copy) BLKeyTouchHandlingBlock touchesMovedBlock;
@property (nonatomic,copy) BLKeyTouchHandlingBlock touchesEndedBlock;

/* コンストラクタ */
- (id)initWithJSON:(NSDictionary*)JSON line:(NSUInteger)line index:(NSUInteger)index;
/* ハンドラをセット */
- (void)setTouchesBeganBlock:(BLKeyTouchHandlingBlock)began
           touchesMovedBlock:(BLKeyTouchHandlingBlock)moved
           touchesEndedBlock:(BLKeyTouchHandlingBlock)ended;


@end
