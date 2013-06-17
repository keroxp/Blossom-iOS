//
//  BLKeyboardViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/27.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLMainKeyboardViewController.h"
#import "BLCandidateViewController.h"

@interface BLKeyboard : NSObject
<BLCandidateViewControllerDelegate>

@property (nonatomic, readonly) BLMainKeyboardViewController *mainKeyboardViewController;
@property (nonatomic, readonly) BLCandidateViewController *candidateViewController;
@property (weak,nonatomic) UITextView *client;

- (id)initWithClient:(UITextView*)client;

@end
