//
//  BPKeyboardViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/04.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory All rights reserved.
//

#import "BLKeyboardViewController.h"
#import "BLPieView.h"
#import "BLKey.h"
#import "BLKeyboard.h"

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
    /* 行列 */
    NSMutableArray *_rows;
}

/* エンターキー */
@property () BLKey *enterKey;
/* スペースキー */
@property () BLKey *spaceKey;

@end

@implementation BLKeyboardViewController

@synthesize keys = _keys;

- (id)initWithDelegate:(id<BLKeyboardViewControllerDelegate>)delegate
{
    if (self = [super initWithNibName:@"BLKeyboardViewController" bundle:[NSBundle mainBundle]]) {
        // デリゲート
        self.delegate = delegate;
        // キーボードデータを読み込み
        NSString *path = [[NSBundle mainBundle] pathForResource:@"keyboard" ofType:@"json"];
        NSString *jsonstr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSError *e = nil;
        NSArray *rows = [jsonstr objectFromJSONStringWithParseOptions:JKParseOptionNone error:&e];
        _rows = @[@[].mutableCopy,@[].mutableCopy,@[].mutableCopy,@[].mutableCopy].mutableCopy;
        _keys = @[].mutableCopy;
        _currentDirection = -1;
        // キーボードを作成
        [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
            [(NSArray*)obj enumerateObjectsUsingBlock:^(id obj2, NSUInteger j, BOOL *stop2) {
                // Keyをインスタンス化
                BLKey *key = [[BLKey alloc] initWithJSON:(NSDictionary*)obj2 line:i index:j];
                [key setTouchesBeganBlock:^(BLKey *key_, NSSet *touches, UIEvent *event) {
                    [self touchesBegan:touches withEvent:event onKey:key_];
                } touchesMovedBlock:^(BLKey *key_, NSSet *touches, UIEvent *event) {
                    [self touchesMoved:touches withEvent:event onKey:key_];
                } touchesEndedBlock:^(BLKey *key_, NSSet *touches, UIEvent *event) {
                    [self touchesEnded:touches withEvent:event onKey:key_];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputModeDidChange:) name:BLKeyboardInputModeDidChangeNotification object:nil];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self finishHandling:_currentKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification

- (void)inputModeDidChange:(NSNotification*)notification
{
    BLInputMode mode = [[notification object] integerValue];
    switch (mode) {
        case BLInputModeAlphabet:{
            [_spaceKey setTitle:NSLocalizedString(@"", ) forState:UIControlStateNormal];
        }
            break;
        case BLInputModeRomaKana:{
            [_spaceKey setTitle:NSLocalizedString(@"変換", ) forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Rotatation and Layout

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

#pragma mark - Touch Handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event onKey:(BLKey*)key
{
    [key setHighlighted:YES];
    // マルチタッチは検知しない
    if (_currentTouch) return;
    // 代入
    _currentTouch = [touches anyObject];
    _beginPoint = [[touches anyObject] locationInView:self.view];
    // 擬似ハンドラへ
    [self keyDidTouchDown:key];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event onKey:(BLKey*)key
{
    for (UITouch *t in touches) {
        // 現在のタッチでなければハンドリングしない
        if (t == _currentTouch) {
            CGPoint cur = [_currentTouch locationInView:self.view];
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
            //ポップアップを更新
            [_currentPopup setTitle:[pv.pieces objectAtIndex:dir] forState:UIControlStateNormal];
            // 方向を保存
            _currentDirection = dir;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event onKey:(BLKey*)key
{
    [key setHighlighted:NO];
    for (UITouch*t in touches) {
        if (t == _currentTouch) {
            _endPoint = [t locationInView:self.view];
            // キーの内部でタッチが終わったか？
            BOOL inside = CGRectContainsPoint(key.frame, [t locationInView:self.view]);
            // それによって擬似ハンドラを振り分け
            if (inside) {
                [self keyDidTouchUpInside:key];
            }else{
                [self keyDidTouchUpOutSide:key];
            }
        }
    }
}

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
        [self.delegate keyboardViewController:self didInputText:add];
    }else{
        // 特殊キー
        NSString *s = [sender keystr];
        if ([s isEqualToString:@"enter"]) {
            // エンター
            [self.delegate keyboardViewController:self didInputCommand:BLKeyboardCommandEnter];
        }else if ([s isEqualToString:@"space"]){
            // スペース
            [self.delegate keyboardViewController:self didInputCommand:BLKeyboardCommandSpace];
        }else if ([s isEqualToString:@"delete"]){
            // デリート
            [self.delegate keyboardViewController:self didInputCommand:BLKeyboardCommandDelete];
        }else if ([s isEqualToString:@"small"]){
            // 小文字
            [self.delegate keyboardViewController:self didInputCommand:BLKeyboardCommandSmall];
        }else if ([s isEqualToString:@"close"]){
            // 閉じる
            [self.delegate keyboardViewController:self didInputCommand:BLKeyboardCommandClose];
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
        NSString *add = [pv.pieces objectAtIndex:[self indexFromDirection:dir]];
        // 移譲
        [self.delegate keyboardViewController:self didInputText:add];
    }
    
    [self finishHandling:sender];
}

- (void)repeatKeyAction:(BLKey*)key
{
    _repeatTimer = [NSTimer scheduledTimerWithTimeInterval:kKeyRepeatWait block:^(NSTimeInterval time) {
        NSString *k = key.keystr;
        if ([k isEqualToString:@"enter"]) {
            [self.delegate keyboardViewController:self didInputCommand:BLKeyboardCommandEnter];
        }else if ([k isEqualToString:@"space"]){
            [self.delegate keyboardViewController:self didInputCommand:BLKeyboardCommandSpace];
        }else if ([k isEqualToString:@"delete"]){
            [self.delegate keyboardViewController:self didInputCommand:BLKeyboardCommandDelete];
        }
    } repeats:YES];
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
