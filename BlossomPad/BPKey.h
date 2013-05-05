//
//  BPKey.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>

@class  BPKey;
typedef void (^BPKeyTouchHandlingBlock)(BPKey* key, NSSet *touches, UIEvent* event);

@interface BPKey : UIButton

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
/* アイコン（optional） */
@property (nonatomic) UIImage *icon;
/*  */
@property (nonatomic) NSString *keystr;
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
@property (nonatomic,copy) BPKeyTouchHandlingBlock touchesBeganBlock;
@property (nonatomic,copy) BPKeyTouchHandlingBlock touchesMovedBlock;
@property (nonatomic,copy) BPKeyTouchHandlingBlock touchesEndedBlock;

/* コンストラクタ */
- (id)initWithJSON:(NSDictionary*)JSON line:(NSUInteger)line index:(NSUInteger)index;
/* ハンドラをセット */
- (void)setTouchesBeganBlock:(BPKeyTouchHandlingBlock)began
           touchesMovedBlock:(BPKeyTouchHandlingBlock)moved
           touchesEndedBlock:(BPKeyTouchHandlingBlock)ended;

- (void)needsLayoutForOrientation:(UIDeviceOrientation)orientation;

@end
