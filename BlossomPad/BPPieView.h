//
//  BPPieView.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BPPieView : UIView

/* Shared Instance */
+ (BPPieView*)sharedView;
/* みせる */
+ (void)showInView:(UIView*)view
           atPoint:(CGPoint)point
        centerChar:(NSString*)centerChar
            pieces:(NSArray*)pieces;
/* 隠す */
+ (void)hide;
/* 中央の文字 */
@property (nonatomic, readonly) NSString *centerChar;
/* ピース文字 */
@property (nonatomic, readonly) NSArray *pieces;
/* ピースの実体。UIButotn */
@property (nonatomic) NSArray *piePieces;
/*  */
@property (nonatomic) BOOL isShowing;

/* セッター */
- (void)setCenterChar:(NSString *)centerChar pieces:(NSArray *)pieces;
/*  */
- (void)setHighlited:(BOOL)highlited atIndex:(NSUInteger)index;

@end
