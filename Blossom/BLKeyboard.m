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
#import "BLResource.h"
#import "UIView+FrameChange.h"

NSString *const BLKeyboardInputModeDidChangeNotification = @"BLKeyboardInputModeDidChangeNotification";

@interface BLKeyboard (){
    // 入力された文字列
    NSMutableString *_originalBuffer;
    // 入力から修正もしくは変換された文字列
    NSMutableString *_compoesdBuffer;
    NSMutableString *_romaBuffer;
    
}


- (void)appendOriginalBuffer:(NSString*)text;
- (void)deleteOriginalBuffer;

- (void)appendComposedBuffer:(NSString*)text;
- (void)deleteComposedBuffer;

- (void)handleSpace;
- (void)handleDelete;
- (void)handleEnter;
- (void)handleSmall;

@end

@implementation BLKeyboard

- (id)init
{
    if (self = [super init]) {
        BLKeyboardViewController *kvc = [[BLKeyboardViewController alloc] initWithDelegate:self];
        BLCandidateViewController *cvc = [[BLCandidateViewController alloc] initWithDelegate:self];
        _candidateViewController = cvc;
        _mainKeyboardViewController = kvc;
        _inputMode = BLInputModeAlphabet;
        _originalBuffer = [[NSMutableString alloc] init];
        _compoesdBuffer = [[NSMutableString alloc] init];
        _romaBuffer = [[NSMutableString alloc] init];
    }
    return self;
}

- (id)initWithClient:(UITextView *)client
{
    if (self = [self init]) {
        _client = client;
    }
    return self;
}

#pragma mark - Candidate Delegate

- (void)candidateController:(BLCandidateViewController *)controller didSelectCandidate:(BLDictEntry *)candidate
{
    // 単語を挿入
    [self.client insertText:candidate.word];
    // 閉める
    [self toggleCandidateView:NO];
    //
    [_originalBuffer setString:@""];
}

- (void)candidateController:(BLCandidateViewController *)controller
         toggleButtonDidTap:(UIButton *)sender
                       open:(BOOL)open
{
    [self toggleCandidateView:open];
}

- (void)toggleCandidateView:(BOOL)open
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
    self.candidateViewController.view.frame = cf;
}

#pragma mark - Keboard View Delegate

- (void)keyboardViewController:(BLKeyboardViewController *)controller
                  didInputText:(NSString *)text
{
//    if ([text isKana]) {
//        [self appendComposedBuffer:text];
//    }else{
//        [self appendOriginalBuffer:text];
//    }
    [self appendOriginalBuffer:text];
}

- (void)keyboardViewController:(BLKeyboardViewController *)controller
               didInputCommand:(BLKeyboardCommand)command
{
    switch (command) {
        case BLKeyboardCommandClose:
            [self.client resignFirstResponder];
            break;
        case BLKeyboardCommandDelete:
            [self handleDelete];
            break;
        case BLKeyboardCommandEnter:
            [self handleEnter];
            break;
        case BLKeyboardCommandSmall:
            [self handleSmall];
            break;
        case BLKeyboardCommandSpace:
            [self handleSpace];
            break;
        default:
            break;
    }
}

#pragma mark - Key Handler


- (void)setInputMode:(BLInputMode)inputMode
{
    if (inputMode != _inputMode) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BLKeyboardInputModeDidChangeNotification object:@(inputMode)];
        _inputMode = inputMode;
    }
}

- (void)handleSpace
{
    if (self.inputMode == BLInputModeRomaKana) {
        // 変換
        [self.candidateViewController convertBuffer];
    }else{
        [self.client unmarkText];
        [self setInputMode:BLInputModeAlphabet];
        [self.client insertText:@" "];
    }
}

- (void)handleDelete
{
    if (_originalBuffer.length > 0) {
        // バッファがあればバッファから文字を削除
        [_originalBuffer deleteCharactersInRange:NSMakeRange(_originalBuffer.length - 1, 1)];
        [self.client setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
        [self.candidateViewController presentSuggestion:_originalBuffer];
    }else{
        // なければフィールドから文字を削除
        [_originalBuffer setString:@""];
        [self.client deleteBackward];
    }
    if (_romaBuffer.length > 0) {
        [_romaBuffer deleteCharactersInRange:NSMakeRange(_romaBuffer.length - 1, 1)];
    }else{
        [_romaBuffer setString:@""];
    }
}

- (void)handleEnter
{
    // バッファを空に
    if ([self.client textInRange:[self.client markedTextRange]]) {
        // マークを外す
        [self.client unmarkText];
        [self setInputMode:BLInputModeAlphabet];
    }else{
        // 改行
        [self.client insertText:@"\n"];
    }
}

- (void)handleSmall3
{
    if (_originalBuffer.length > 0) {
        //あいうえおやゆよつわ
        NSString *tail = [_originalBuffer substringWithRange:NSMakeRange(_originalBuffer.length - 1, 1)];
        NSString *convert = [[BLResource sharedSmalls] objectForKey:tail];
        //                    NSLog(@"tail : %@, concert : %@",tail,convert);
        if (convert) {
            [_originalBuffer replaceCharactersInRange:NSMakeRange(_originalBuffer.length - 1, 1) withString:convert];
            [self.client setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
        }
    }
}

#pragma mark - Bufferring and Composing

- (void)appendOriginalBuffer:(NSString *)text
{
    NSString *add = text;
    // コレクト処理
    if (_originalBuffer.length == 0) {
        // インプットモードの変更
        if ([text isKana]) {
            [self setInputMode:BLInputModeRomaKana];
            [_originalBuffer setString:add];
            [self.candidateViewController presentSuggestion:_originalBuffer];
            [self.client setMarkedText:add selectedRange:NSMakeRange(add.length, 0)];
        }else{
            [self setInputMode:BLInputModeAlphabet];
            [self.client insertText:add];
        }
    }else if (_originalBuffer.length > 0) {
        // バッファに格納
        if (self.inputMode == BLInputModeAlphabet) { // 英字入力モード
            [self.client insertText:text];
        }else if (self.inputMode == BLInputModeRomaKana) {  // ローマ字入力モード
            [_originalBuffer appendString:add];
            
            NSString *ms = [add mutableCopy];
            // 半角に戻す
            CFStringTransform((CFMutableStringRef)ms, NULL, kCFStringTransformFullwidthHalfwidth, false);
            
            // ローマ字バッファに格納
            if ([ms isLetter]) {
                TFLog(@"ms:ｙｔｋ%@",ms);
                // 半角に戻す
                [_romaBuffer appendString:ms];
            }else{
                [_romaBuffer setString:@""];
            }
            
            // ローマ字入力
            if ([[BLResource sharedRomaKana] objectForKey:_romaBuffer]){
                // 変換
                NSString *converted = [[BLResource sharedRomaKana] objectForKey:_romaBuffer];
                [_originalBuffer deleteCharactersInRange:NSMakeRange(_originalBuffer.length - _romaBuffer.length, _romaBuffer.length)];
                [_originalBuffer appendString:converted];
                [self.client setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
                [_romaBuffer setString:@""];
                TFLog(@"rome converted");
                [self.candidateViewController presentSuggestion:_originalBuffer];
                return;
            }
            
            NSString *before = [_originalBuffer substringWithRange:NSMakeRange(_originalBuffer.length - 2, 1)];
            
            // 連続文字の処理
            if ([text isLetter] && [before isEqualToString:text]) {
                // 「っ」
                [_originalBuffer deleteCharactersInRange:NSMakeRange(_originalBuffer.length - 2, 2)];
                [_originalBuffer appendString:@"っ"];
            }
            
            // はさみうちの処理
            if (_originalBuffer.length > 2) {
                NSString *head = [_originalBuffer substringWithRange:NSMakeRange(_originalBuffer.length - 3, 1)];
                TFLog(@"head is %@, body is %@, tail is %@ ",head,before,add);
                if ([head isKana] && [before isLetter] && [add isKana]) {
                    if ([before isEqualToString:@"n"]) {
                        [_originalBuffer replaceCharactersInRange:NSMakeRange(_originalBuffer.length - 2, 1) withString:@"ん"];
                    }else{
                        [_originalBuffer replaceCharactersInRange:NSMakeRange(_originalBuffer.length - 2, 1) withString:@"っ"];
                    }
                }
            }
            // 文字をセット
            [self.client setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
            if(text.isKana){
                // 候補の作成
                [self.candidateViewController presentSuggestion:_originalBuffer];
            }
        }
    }
}

- (void)deleteOriginalBuffer
{
    
}

- (void)deleteComposedBuffer
{
    
}

@end
