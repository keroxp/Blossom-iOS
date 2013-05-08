//
//  BPKeyboardViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPCandidateViewController.h"
@interface BPKeyboardViewController : UIViewController
<BPCandidateViewControllerDelegate>

/* 入力先 */
@property (weak) UIResponder<UITextInput,UIKeyInput> *activeClient;
/* キーボードの行 */
@property (readonly) NSArray *rows;
@property (readonly) NSArray *keys;
@property (weak) BPCandidateViewController *candidateViewController;

@end


