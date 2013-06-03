//
//  BPKeyboardViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLCandidateViewController.h"

@class BLKey;
@interface BLMainKeyboardViewController : UIViewController
<BLCandidateViewControllerDelegate>

/* 入力先 */
@property (weak) UIResponder<UITextInput,UIKeyInput> *activeClient;
/* すべてのキー */
@property (readonly) NSArray *keys;
/* 候補ビューコントローラー */
@property (weak) BLCandidateViewController *candidateViewController;
/* コンストラクタ */
- (id)initWithClient:(UIResponder<UITextInput,UIKeyInput>*)client;
/* キーを取得 */
- (BLKey*)keyAtRow:(NSUInteger)row column:(NSUInteger)column;

@end


