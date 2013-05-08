//
//  BPKeyboardViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import "BLKeyboardViewController.h"
#import "BLKey.h"
#import "BLPieView.h"
#import "BPDictionary.h"
#import "BLCandidateViewController.h"
#import "NSString+isKana.h"

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


/* フリックの方向 */
typedef enum{
    BLTouchDirectionUP = 0,
    BLTouchDirectionUpRight,
    BLTouchDirectionDownRight,
    BLTouchDirectionDownLeft,
    BLTouchDirectionUpLeft
}BLTouchDirection;

/* 入力モード */
typedef enum{
    BPInputModeAlphabet = 0,
    BPInputModeRomaKana
}BPInputMode;


@interface BLKeyboardViewController ()
{
    // 現在のタッチ
    UITouch *_currentTouch;
    // 現在のキー
    BLKey *_currentKey;
    // 現在のポップアップ
    UIButton *_currentPopup;
    // 現在のタッチ方向
    BLTouchDirection _currentDirection;
    // 現在表示されているPieViewの格納庫
    NSMutableDictionary *_currentPies;
    // 最初のタッチポイント
    CGPoint _beginPoint;
    // 最後のタッチポイント
    CGPoint _endPoint;
    // keys
    NSMutableArray *_keys;
    // リピートキーのタイマー
    NSTimer *_repeatTimer;
    /*  */
    NSMutableArray *_rows;
}

/* キーから入力された文字列バッファ */
@property (strong, nonatomic) NSMutableString *originalBuffer;
/* 内部的な変換処理が施されたひらがな文字列 */
@property (strong, nonatomic) NSMutableString *composedBuffer;
/* ローマ字入力モードの際のアルファベット文字列 */
@property (strong, nonatomic) NSMutableString *romaBuffer;
/* 入力モード */
@property (assign, nonatomic) BPInputMode inputMode;
/* エンターキー */
@property () BLKey *enterKey;
/* スペースキー */
@property () BLKey *spaceKey;

@end

@implementation BLKeyboardViewController

@synthesize keys = _keys;

- (id)initWithClient:(UIResponder<UITextInput,UIKeyInput> *)client
{
    if (self = [super initWithNibName:@"BLKeyboardViewController" bundle:[NSBundle mainBundle]]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"keyboard" ofType:@"json"];
        NSString *jsonstr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSError *e = nil;
        NSArray *rows = [jsonstr objectFromJSONStringWithParseOptions:JKParseOptionNone error:&e];
        _rows = @[@[].mutableCopy,@[].mutableCopy,@[].mutableCopy,@[].mutableCopy].mutableCopy;
        _keys = @[].mutableCopy;
        _originalBuffer = [NSMutableString string];
        _romaBuffer = [NSMutableString string];
        _inputMode = BPInputModeAlphabet;
        _activeClient = client;
        // キーボードを作成
        [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
            [(NSArray*)obj enumerateObjectsUsingBlock:^(id obj2, NSUInteger j, BOOL *stop2) {
                // Keyをインスタンス化
                BLKey *key = [[BLKey alloc] initWithJSON:(NSDictionary*)obj2 line:i index:j];
                __block BLKeyboardViewController *__self = self;
                [key setTouchesBeganBlock:^(BLKey *key_, NSSet *touches, UIEvent *event) {
                    [key_ setHighlighted:YES];
                    // マルチタッチは検知しない
                    if (_currentTouch) return;
                    // リファレンス・アサイン
                    _currentTouch = [touches anyObject];
                    _beginPoint = [[touches anyObject] locationInView:__self.view];
                    // 擬似ハンドラへ
                    [self keyDidTouchDown:key_];
                } touchesMovedBlock:^(BLKey *key_, NSSet *touches, UIEvent *event) {
                    for (UITouch *t in touches) {
                        // 現在のタッチでなければハンドリングしない
                        if (t == _currentTouch) {
                            CGPoint cur = [_currentTouch locationInView:__self.view];
                            BLTouchDirection dir = [self getDirection:cur from:_beginPoint];
                            // 同じ方向にいる場合は処理を行わない
                            if (dir == _currentDirection) {
                                return ;
                            }
                            BLPieView *pv = [BLPieView sharedView];
                            // 一度全てを非選択に
                            for (UIButton*b in pv.piePieces) {
                                b.highlighted = NO;
                            }
                            // 指定方向のパイピースをハイライト
                            [pv setHighlited:YES atIndex:dir];
                            // 音を鳴らす
                            //AudioServicesPlaySystemSound(1104);
                            //ポップアップを更新
                            [_currentPopup setTitle:[pv.pieces objectAtIndex:dir] forState:UIControlStateNormal];
                            // 方向を保存
                            _currentDirection = dir;
                        }
                    }
                } touchesEndedBlock:^(BLKey *key_, NSSet *touches, UIEvent *event) {
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
                if ([key.keystr isEqualToString:@"enter"]) {
                    _enterKey = key;
                }else if ([key.keystr isEqualToString:@"space"]){
                    _spaceKey = key;
                }
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
                                             selector:@selector(deviceDidRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    [_rows enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
        totalMarginY += kKeyMarginUp;
        [(NSArray*)obj enumerateObjectsUsingBlock:^(id obw2, NSUInteger j, BOOL *stop2) {
            BLKey *key = (BLKey*)obw2;
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
                if (i == 1) f = CGRectMake(kRow2MarginLeft*3/4+x*3/4,y*3/4,w*3/4,h*3/4);
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

#pragma mark - Public

- (BLKey *)keyAtRow:(NSUInteger)row column:(NSUInteger)column
{
    return _rows[row][column];
}

#pragma mark - Key Handler

- (void)keyDidTouchDown:(BLKey *)sender
{
    // 音を鳴らす
    AudioServicesPlaySystemSound(1104);
    // 凹ませる
    BLPieView *pv = [BLPieView sharedView];
    if (sender.pieces.count > 0) {
        // そうでないなら新規に構築
        if ([pv isShowing]) {
            [BLPieView hide];
        }
        CGPoint c = sender.center;
        c.y += 55.0f;
        [BLPieView showInView:self.view.superview atPoint:c centerChar:sender.keystr pieces:sender.pieces];
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

- (void)keyDidTouchUpInside:(BLKey *)sender
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
            if (self.inputMode == BPInputModeRomaKana) {
                // 変換
                [self.candidateViewController performConversion];
            }else{
                [self.activeClient unmarkText];
                [self setInputMode:BPInputModeAlphabet];
                [self.activeClient insertText:@" "];                
            }
        }else if ([s isEqualToString:@"delete"]){ // デリート
            if (_originalBuffer.length > 0) {
                // バッファがあればバッファから文字を削除
                [_originalBuffer deleteCharactersInRange:NSMakeRange(_originalBuffer.length - 1, 1)];
                [self.activeClient setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
                [self.candidateViewController setHiraBuffer:[_originalBuffer copy]];
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
        }else if ([s isEqualToString:@"close"]){
            [self.activeClient resignFirstResponder];
        }
    }    
    [self finishHandling:sender];
}

- (void)keyDidTouchUpOutSide:(BLKey *)sender
{
    [sender setHighlighted:NO];
    BLPieView *pv = [BLPieView sharedView];
    BLTouchDirection dir = [self getDirection:_endPoint from:_beginPoint];
    
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

- (void)repeatKeyAction:(BLKey*)key
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

#pragma mark - Bufferring and Composing

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
                TFLog(@"ms:ｙｔｋ%@",ms);
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
                TFLog(@"rome converted");
                [self.candidateViewController setHiraBuffer:_originalBuffer];
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
            [self.activeClient setMarkedText:_originalBuffer selectedRange:NSMakeRange(_originalBuffer.length, 0)];
            // 候補の作成
            [self.candidateViewController setHiraBuffer:[_originalBuffer copy]];
        }
    }
}

- (void)setInputMode:(BPInputMode)inputMode
{
    if (inputMode != _inputMode) {
        [_romaBuffer setString:@""];
        [_originalBuffer setString:@""];
        if (inputMode == BPInputModeRomaKana) {
            [self.spaceKey setTitle:NSLocalizedString(@"変換", ) forState:UIControlStateNormal];
        }else{
            [self.spaceKey setTitle:@"" forState:UIControlStateNormal];
        }
        _inputMode = inputMode;
    }
}

- (void)finishHandling:(BLKey*)sender
{
    // リピート処理を止める
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_repeatTimer invalidate];
    _repeatTimer = nil;
    // PieViewを消す
    BLPieView *pv = [BLPieView sharedView];
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

- (void)candidateController:(BLCandidateViewController *)controller didSelectCandidate:(NSString *)candidate
{
    [self.activeClient insertText:candidate];
    [self setInputMode:BPInputModeAlphabet];
}


#pragma mark - Utility

- (NSInteger)indexFromDirection:(BLTouchDirection)direction
{
    switch (direction) {
        case BLTouchDirectionUP: return 0;
        case BLTouchDirectionUpRight: return 1;
        case BLTouchDirectionDownRight: return 2;
        case BLTouchDirectionDownLeft: return 3;
        case BLTouchDirectionUpLeft: return 4;
        default:
            break;
    }
    return -1;
}

- (BLTouchDirection)getDirection:(CGPoint)current from:(CGPoint)previous
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
        return BLTouchDirectionUpRight;
    }else if(PI*3/10  <= angle && angle < PI*7/10 ){
        // 上
        return BLTouchDirectionUP;
    }else if(PI*7/10  <= angle && angle < PI*11/10 ){
        // 左上
        return BLTouchDirectionUpLeft;
    }else if(PI*11/10  <= angle && angle < PI*15/10 ){
        // 左下
        return BLTouchDirectionDownLeft;
    }else if(PI*15/10  <= angle && angle < PI*19/10 ){
        // 右下
        return BLTouchDirectionDownRight;
    }else{
        NSLog(@"invalid angle %f",angle);
    }
    return 0;
}

@end
