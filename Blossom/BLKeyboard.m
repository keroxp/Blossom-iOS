//
//  BLKeyboardViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/27.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLKeyboard.h"
#import "BLDictionary.h"
#import "BLDictEntry.h"
#import "UIView+FrameChange.h"

@interface BLKeyboard ()
{

}

@end

@implementation BLKeyboard

- (id)initWithClient:(UITextView *)client
{
    if (self = [super init]) {
        
        BLMainKeyboardViewController *kvc = [[BLMainKeyboardViewController alloc] initWithClient:client];
        BLCandidateViewController *cvc = [[BLCandidateViewController alloc] initWithDelegate:self];
        
        [kvc setCandidateViewController:cvc];
        _client = client;
        _candidateViewController = cvc;
        _mainKeyboardViewController = kvc;

    }
    return self;
}

#pragma mark - Candidate Delegate

- (void)candidateController:(BLCandidateViewController *)controller didSelectCandidate:(BLDictEntry *)candidate
{
    [self.client insertText:candidate.word];
}

- (void)candidateController:(BLCandidateViewController *)controller toggleButtonDidTap:(UIButton *)sender open:(BOOL)open
{
    CGRect cf = self.client.inputAccessoryView.frame;
    if (!open) {
        // 閉める
        cf.size.height = 55.0f;
    }else{
        // 開ける
        UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
        if (o == UIInterfaceOrientationLandscapeLeft || o == UIInterfaceOrientationLandscapeRight) {
            // 横
            cf.size.height = 396.0f;
        }else{
            // 縦
            cf.size.height = 744.0f;
        }
    }
    self.client.inputAccessoryView.frame = cf;
}

@end
