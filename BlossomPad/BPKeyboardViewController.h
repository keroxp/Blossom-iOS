//
//  BPKeyboardViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BPKeyboardViewController : UIViewController
<UICollectionViewDelegate,UICollectionViewDataSource>

/* 入力先 */
@property (weak) id<UITextInput,UIKeyInput> activeClient;
/* キーボードの行 */
@property (readonly) NSArray *rows;
@property (readonly) NSArray *keys;

@end
