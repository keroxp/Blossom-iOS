//
//  BPKeyboardViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import "BPKeyboardViewController.h"
#import "BPKey.h"
#import "BPPieView.h"
#import "BPDictionary.h"
#import "BPCandidateViewController.h"

#define kKeyboardWidth 1024.f
#define kKeyboardHeight 352.0f

#define kKeyRowHeight 76.0f
#define kKeyRowMargin 10.0f

#define kKeyWidth 82.0f
#define kKeyHeight 74.0f
#define kRow2MarginLeft 40.0f
#define kKeyMarginRight 10.0f
#define kKeyMarginUp 10.0f

#define kDefaultPieViewWidth 200.0f

#define PI 3.1415926535

#define kKeyRepeatInitialWait 0.3
#define kKeyRepeatWait 0.083


// フリックの方向
typedef enum{
    BPDirectionUp = 0,
    BPDirectionUpRight,
    BPDirectionDownRight,
    BPDirectionDownLeft,
    BPDirectionUpLeft
}BPDirection;


typedef enum{
    BPInputModeAlphabet = 0,
    BPInputModeRomaKana
}BPInputMode;


@interface BPKeyboardViewController ()
{
    // 現在のタッチ
    UITouch *_currentTouch;
    // 現在のキー
    BPKey *_currentKey;
    // 現在のポップアップ
    UIButton *_currentPopup;
    // 現在表示されているPieViewの格納庫
    NSMutableDictionary *_currentPies;
    // 最初のタッチポイント
    CGPoint _beginPoint;
    // 最後のタッチポイント
    CGPoint _endPoint;
    // keys
    NSMutableArray *_keys;
    //
    NSTimer *_repeatTimer;
}

@property (strong, nonatomic) NSMutableString *originalBuffer;
@property (strong, nonatomic) NSMutableString *romaBuffer;
@property (assign, nonatomic) BPInputMode inputMode;

@end

@implementation BPKeyboardViewController

@synthesize keys = _keys;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"keyboard" ofType:@"json"];
        NSString *jsonstr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSError *e = nil;
        NSArray *rows = [jsonstr objectFromJSONStringWithParseOptions:JKParseOptionNone error:&e];
        _rows = @[@[].mutableCopy,@[].mutableCopy,@[].mutableCopy,@[].mutableCopy];
        _keys = @[].mutableCopy;
        _originalBuffer = [NSMutableString string];
        _romaBuffer = [NSMutableString string];
        _inputMode = BPInputModeAlphabet;

        [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
            [(NSArray*)obj enumerateObjectsUsingBlock:^(id obj2, NSUInteger j, BOOL *stop2) {
                // Keyをインスタンス化
                BPKey *key = [[BPKey alloc] initWithJSON:(NSDictionary*)obj2 line:i index:j];
                __block BPKeyboardViewController *__self = self;
                [key setTouchesBeganBlock:^(BPKey *key_, NSSet *touches, UIEvent *event) {
                    [key_ setHighlighted:YES];
                    // マルチタッチは検知しない
                    if (_currentTouch) return;
                    // リファレンス・アサイン
                    _currentTouch = [touches anyObject];
                    _beginPoint = [[touches anyObject] locationInView:__self.view];
                    // 擬似ハンドラへ
                    [self keyDidTouchDown:key_];
                } touchesMovedBlock:^(BPKey *key_, NSSet *touches, UIEvent *event) {
                    for (UITouch *t in touches) {
                        // 現在のタッチでなければハンドリングしない
                        if (t == _currentTouch) {
                            CGPoint cur = [_currentTouch locationInView:__self.view];
                            BPDirection dir = [self getDirection:cur from:_beginPoint];
                            BPPieView *pv = [BPPieView sharedView];                            
                            // 一度全てを非選択に
                            for (UIButton*b in pv.piePieces) {
                                b.highlighted = NO;
                            }
                            // 指定方向のパイピースをハイライト
                            [pv setHighlited:YES atIndex:dir];                            
                            //ポップアップを更新
                            [_currentPopup setTitle:[pv.pieces objectAtIndex:dir] forState:UIControlStateNormal];
                        }
                    }
                } touchesEndedBlock:^(BPKey *key_, NSSet *touches, UIEvent *event) {
                    [key_ setHighlighted:NO];
                    for (UITouch*t in touches) {
                        if (t == _currentTouch) {
                            _endPoint = [t locationInView:__self.view];
                            // キーの内部でタッチが終わったか？
                            BOOL inside = CGRectContainsPoint(key_.frame, [t locationInView:__self.view]);
                            // それによって擬似ハンドラを振り分け
                            if (inside) {
                                [self keyDidTouchUpInside:key_];
                            }else{
                                [self keyDidTouchUpOutSide:key_];
                            }
                        }
                    }
                }];
                [self.view addSubview:key];
                [[_rows objectAtIndex:i] addObject:key];
                [_keys addObject:key];
            }];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardSizeDidChange:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];    
    [self layoutKeysForOrientation:[[UIDevice currentDevice] orientation]];
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutKeysForOrientation:(UIDeviceOrientation)orientation
{
    if (orientation == UIDeviceOrientationUnknown) {
        orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    __block CGFloat totalMarginX = 0;
    __block CGFloat totalMarginY = 0;
    [self.rows enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
        totalMarginY += kKeyMarginUp;
        [(NSArray*)obj enumerateObjectsUsingBlock:^(id obw2, NSUInteger j, BOOL *stop2) {
            BPKey *key = (BPKey*)obw2;
            CGRect f = CGRectZero;
            totalMarginX += kKeyMarginRight;
            CGFloat x,y,w,h;
            x = totalMarginX;
            y = totalMarginY;
            w = key.keyWidth;
            h = key.keyHeight;
            if (UIDeviceOrientationIsPortrait(orientation)){
                // たて
                [key.titleLabel setFont:[UIFont systemFontOfSize:20]];
                f = CGRectMake(x*3/4, y*3/4, w*3/4, h*3/4);
                // ２段目をずらす
                if (i == 1) f = CGRectMake(kRow2MarginLeft+x*3/4,y*3/4,w*3/4,h*3/4);
            }else{
                [key.titleLabel setFont:[UIFont systemFontOfSize:25]];
                f = CGRectMake(x, y, w, h);
                // ２段目をずらす
                if (i == 1) f = CGRectMake(kRow2MarginLeft+x,y,w,h);
            }
            [key setFrame:f];
            totalMarginX += key.keyWidth;
        }];
        totalMarginY += kKeyHeight;
        totalMarginX = 0;
    }];
}

- (void)deviceDidRotate:(NSNotification*)notificatoin
{
    UIDeviceOrientation orientation = [notificatoin.object orientation];
    [self layoutKeysForOrientation:orientation];
}
- (void)keyboardSizeDidChange:(NSNotification*)notification
{
    CGRect begin = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect end = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    TFLog(@"begin : %@",NSStringFromCGRect(begin));
    TFLog(@"end : %@",NSStringFromCGRect(end));
}

#pragma mark - Key Handler

- (void)keyDidTouchDown:(BPKey *)sender
{
    // 凹ませる
    BPPieView *pv = [BPPieView sharedView];
    if (sender.pieces.count > 0) {
        // そうでないなら新規に構築
        if ([pv isShowing]) {
            [BPPieView hide];
        }
        CGPoint c = sender.center;
        c.y += 55.0f;
        [BPPieView showInView:self.view.superview atPoint:c centerChar:sender.keystr pieces:sender.pieces];
        // ポップアップを構築
        UIButton *pup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        pup.center = pv.center;
        c = pup.center;
        pup.frame = CGRectMake(c.x - 25, c.y - 200, 50, 50);
        // selfではなく、その上のビューに追加
        [self.view.superview addSubview:pup];
        _currentPopup = pup;
    }
    if (sender.isRepeatable) {
        [self performSelector:@selector(repeatKeyAction:) withObject:sender afterDelay:0.5];
    }
    _currentKey = sender;
}

- (void)keyDidTouchUpInside:(BPKey *)sender
{
    [sender setHighlighted:NO];
    NSString *add = [sender.keystr lowercaseString];    
    // 通常入力
    if (!sender.isFunctional && !sender.isModifier) {
        if (self.inputMode == BPInputModeRomaKana) {
        }
        [self appendOriginalBuffer:add];
    }else{
        // 特殊キー
        NSString *s = [sender keystr];
        if ([s isEqualToString:@"enter"]) { // エンター
            // バッファを空に
            if ([self.activeClient textInRange:[self.activeClient markedTextRange]]) {
                // マークを外す
                [self.activeClient unmarkText];
                [self setInputMode:BPInputModeAlphabet];
            }else{
                // 改行
                [self.activeClient insertText:@"\n"];
            }
        }else if ([s isEqualToString:@"space"]){            
            [self.activeClient unmarkText];
            [self setInputMode:BPInputModeAlphabet];
            [self.activeClient insertText:@" "];
        }else if ([s isEqualToString:@"delete"]){ // デリート
            if (_originalBuffer.length > 0) {
                // バッファがあればバッファから文字を削除
                [_originalBuffer deleteCharactersInRange:NSMakeRange(_originalBuffer.length - 1, 1)];
                [self.activeClient setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
            }else{
                // なければフィールドから文字を削除
                [_originalBuffer setString:@""];
                [self.activeClient deleteBackward];
            }
            if (_romaBuffer.length > 0) {
                [_romaBuffer deleteCharactersInRange:NSMakeRange(_romaBuffer.length - 1, 1)];
            }else{
                [_romaBuffer setString:@""];
            }
        }else if ([s isEqualToString:@"small"]){ // 小文字
            if (_originalBuffer.length > 0) {
                //あいうえおやゆよつわ
                NSString *tail = [_originalBuffer substringWithRange:NSMakeRange(_originalBuffer.length - 1, 1)];
                NSString *convert = [[BPDictionary sharedSmalls] objectForKey:tail];
//                    NSLog(@"tail : %@, concert : %@",tail,convert);
                if (convert) {
                    [_originalBuffer replaceCharactersInRange:NSMakeRange(_originalBuffer.length - 1, 1) withString:convert];
                    [self.activeClient setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
                }
            }
        }
    }    
    [self finishHandling:sender];
}

- (void)keyDidTouchUpOutSide:(BPKey *)sender
{
    [sender setHighlighted:NO];
    BPPieView *pv = [BPPieView sharedView];
    BPDirection dir = [self getDirection:_endPoint from:_beginPoint];
    
    // フリック入力
    if (pv.pieces.count > 0){
        if (self.inputMode == BPInputModeAlphabet) {
            [self setInputMode:BPInputModeAlphabet];
        }
        NSString *add = [pv.pieces objectAtIndex:[self indexFromDirection:dir]];
        [self appendOriginalBuffer:add];
    }
    
    [self finishHandling:sender];
}

- (void)repeatKeyAction:(BPKey*)key
{
    _repeatTimer = [NSTimer scheduledTimerWithTimeInterval:kKeyRepeatWait block:^(NSTimeInterval time) {
        NSString *k = key.keystr;
        if ([k isEqualToString:@"enter"]) {
            [self.activeClient insertText:@"\n"];
        }else if ([k isEqualToString:@"space"]){
            [self.activeClient insertText:@" "];
        }else if ([k isEqualToString:@"delete"]){
            [self.activeClient deleteBackward];
        }
    } repeats:YES];
}

- (void)searchCandidatesForPattern:(NSString*)pattern
{
    
}

- (void)appendOriginalBuffer:(NSString*)character
{
    NSString *add = character;    
    // コレクト処理
    if (_originalBuffer.length == 0) {
        // インプットモードの変更
        if ([character isKana]) {
            [self setInputMode:BPInputModeRomaKana];
            [_originalBuffer setString:add];
            [self.activeClient setMarkedText:add selectedRange:NSMakeRange(add.length, 0)];
        }else{
            [self setInputMode:BPInputModeAlphabet];
            [self.activeClient insertText:add];
        }
    }else if (_originalBuffer.length > 0) {
        // バッファに格納        
        if (self.inputMode == BPInputModeAlphabet) { // 英字入力モード
            [self.activeClient insertText:character];
        }else if (self.inputMode == BPInputModeRomaKana) {  // ローマ字入力モード            
            [_originalBuffer appendString:add];
            
            NSString *ms = [add mutableCopy];
            // 半角に戻す
            CFStringTransform((CFMutableStringRef)ms, NULL, kCFStringTransformFullwidthHalfwidth, false);
            
            // ローマ字バッファに格納
            if ([ms isLetter]) {
                NSLog(@"ms:ｙｔｋ%@",ms);
                // 半角に戻す
                [_romaBuffer appendString:ms];
            }else{
                [_romaBuffer setString:@""];
            }
            
            // ローマ字入力
            if ([[BPDictionary sharedRomaKana] objectForKey:_romaBuffer]){
                // 変換
                NSString *converted = [[BPDictionary sharedRomaKana] objectForKey:_romaBuffer];
                [_originalBuffer deleteCharactersInRange:NSMakeRange(_originalBuffer.length - _romaBuffer.length, _romaBuffer.length)];
                [_originalBuffer appendString:converted];
                [self.activeClient setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
                [_romaBuffer setString:@""];
                NSLog(@"rome converted");
                return;
            }
            
            NSString *before = [_originalBuffer substringWithRange:NSMakeRange(_originalBuffer.length - 2, 1)];
            
            // 連続文字の処理
            if ([character isLetter] && [before isEqualToString:character]) {
                // 「っ」
                [_originalBuffer deleteCharactersInRange:NSMakeRange(_originalBuffer.length - 2, 2)];
                [_originalBuffer appendString:@"っ"];
            }
            
            // はさみうちの処理
            if (_originalBuffer.length > 2) {
                NSString *head = [_originalBuffer substringWithRange:NSMakeRange(_originalBuffer.length - 3, 1)];
                NSLog(@"head is %@, body is %@, tail is %@ ",head,before,add);
                if ([head isKana] && [before isLetter] && [add isKana]) {
                    if ([before isEqualToString:@"n"]) {
                        [_originalBuffer replaceCharactersInRange:NSMakeRange(_originalBuffer.length - 2, 1) withString:@"ん"];
                    }else{
                        [_originalBuffer replaceCharactersInRange:NSMakeRange(_originalBuffer.length - 2, 1) withString:@"っ"];
                    }
                }
            }
            // 文字をセット
            [self.activeClient setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
            // 変換
            [self.candidateViewController generaetCandidateWithText:_originalBuffer];
        }
    }
}

- (void)setInputMode:(BPInputMode)inputMode
{
    if (inputMode != _inputMode) {
        [_romaBuffer setString:@""];
        [_originalBuffer setString:@""];
        _inputMode = inputMode;
    }
}

- (void)finishHandling:(BPKey*)sender
{
    // リピート処理を止める
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_repeatTimer invalidate];
    _repeatTimer = nil;
    // PieViewを消す
    BPPieView *pv = [BPPieView sharedView];
    if (pv) {
        [pv removeFromSuperview];
        [_currentPies removeObjectForKey:sender.keystr];
    }
    [_currentPopup removeFromSuperview];
    
    _currentKey = nil;
    _currentTouch = nil;
    _currentPopup = nil;
}

#pragma mark - CDDelegate

- (void)candidateController:(BPCandidateViewController *)controller didSelectCandidate:(NSString *)candidate
{
    [self.activeClient insertText:candidate];
    [self setInputMode:BPInputModeAlphabet];
}

#pragma mark - Utility

- (NSInteger)indexFromDirection:(BPDirection)direction
{
    switch (direction) {
        case BPDirectionUp:
            return 0;
            break;
        case BPDirectionUpRight:
            return 1;
            break;
        case BPDirectionDownRight:
            return 2;
            break;
        case BPDirectionDownLeft:
            return 3;
            break;
        case BPDirectionUpLeft:
            return 4;
        default:
            break;
    }
}

- (BPDirection)getDirection:(CGPoint)current from:(CGPoint)previous
{
    CGFloat dx = current.x - previous.x;
    CGFloat dy = current.y - previous.y;
    CGFloat angle = -atan2(dy, dx);
    
    //    NSLog(@"current %f, %f",current.x,current.y);
    //    NSLog(@"prev %f, %f",previous.x,previous.y);
    //    NSLog(@"angle : %f",angle*180/PI);
    
    if (angle < 0) angle += PI*2;
    
    if((0 <= angle && angle < PI*3/10) || (PI*19/10 <= angle && angle <= PI*2)){
        // 右上
        return BPDirectionUpRight;
    }else if(PI*3/10  <= angle && angle < PI*7/10 ){
        // 上
        return BPDirectionUp;
    }else if(PI*7/10  <= angle && angle < PI*11/10 ){
        // 左上
        return BPDirectionUpLeft;
    }else if(PI*11/10  <= angle && angle < PI*15/10 ){
        // 左下
        return BPDirectionDownLeft;
    }else if(PI*15/10  <= angle && angle < PI*19/10 ){
        // 右下
        return BPDirectionDownRight;
    }else{
        NSLog(@"invalid angle %f",angle);
    }
    return 0;
}

@end
