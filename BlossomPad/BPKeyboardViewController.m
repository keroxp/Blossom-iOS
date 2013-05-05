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
#import "BPCandidateViewController.h"

#define kKeyboardWidth 1024.f
#define kKeyboardHeight 352.0f

#define kKeyRowHeight 76.0f
#define kKeyRowMargin 10.0f

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
    [self.keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(BPKey*)obj needsLayoutForOrientation:orientation];
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

- (void)keyDidTouchUpInside:(BPKey *)sender
{
    NSLog(@"touch up inside : %@", sender.keystr);
    BPPieView *pv = [BPPieView sharedView];    
    // 通常入力
    if (sender.isFunctional) {
        NSString *k = sender.keystr;
        if ([k isEqualToString:@"enter"]) {
            [self.activeClient insertText:@"\n"];
        }else if ([k isEqualToString:@"space"]){
            [self.activeClient insertText:@" "];
        }else if ([k isEqualToString:@"delete"]){
            [self.activeClient deleteBackward];
        }
    }else{
        [self.activeClient insertText:pv.centerChar];
    }
    [self finishHandling:sender];
}

- (void)keyDidTouchUpOutSide:(BPKey *)sender
{
    NSLog(@"touch up outside : %@", sender.keystr);
    [sender setHighlighted:NO];
    BPPieView *pv = [BPPieView sharedView];
    BPDirection dir = [self getDirection:_endPoint from:_beginPoint];
    
    if (pv.pieces.count > 0){
        NSString *s = [pv.pieces objectAtIndex:[self indexFromDirection:dir]];
        [self.activeClient insertText:s];
    }
    
    [self finishHandling:sender];
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
