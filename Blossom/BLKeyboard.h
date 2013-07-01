//
//  BLKeyboardViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/27.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKeyboardViewController.h"
#import "BLCandidateViewController.h"

extern NSString *const BLKeyboardInputModeDidChangeNotification;

/* 入力モード */
typedef enum{
    BLInputModeAlphabet = 0,
    BLInputModeRomaKana
}BLInputMode;

@interface BLKeyboard : NSObject
<BLKeyboardViewControllerDelegate
,BLCandidateViewControllerDelegate>

@property (nonatomic, readonly) BLKeyboardViewController *mainKeyboardViewController;
@property (nonatomic, readonly) BLCandidateViewController *candidateViewController;
@property (weak,nonatomic) UITextView *client;
@property (readonly) BLInputMode inputMode;

- (id)initWithClient:(UITextView*)client;

@end
