//
//  BPCandidateViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLCandidateViewController.h"
#import "BLKeyboardViewController.h"
#import "BLCandidateCell.h"
#import "BLResource.h"
#import "BLDictionary.h"
#import "BLDictEntry.h"
#import "BLKeyboard.h"

#define kCellID @"CANDIDATE_CELL"

@interface BLCandidateViewController ()
{
    // 現在表示している候補
    NSMutableArray *_candidates;
    // バッファの追加・削除毎に結果を保持しておくKVS
    NSMutableDictionary *_candidatesStack;
    //
    NSMutableString *_buffer;
    // 前回の辞書検索で結果が見つかったか
    BOOL _found;
    // 連文節変換変換済みか
    BOOL _converted;
    // 選択中の候補
    NSUInteger _selectionIndex;
}

- (void)setCandidates:(NSArray*)candidates;
- (void)appendCandidates:(NSArray*)candidates;
- (void)removeCandidates;

@property (weak, nonatomic) IBOutlet UIButton *tb;
@property (weak, nonatomic) IBOutlet UICollectionView *candidateView;

@end

@implementation BLCandidateViewController

- (id)initWithDelegate:(id<BLCandidateViewControllerDelegate>)delegate
{
    self = [super initWithNibName:@"BLCandidateViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        _delegate = delegate;
        //　候補バッファを作成
        _candidates = [NSMutableArray array];
        _candidatesStack = [NSMutableDictionary dictionary];
        _buffer = [NSMutableString string];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.candidateView registerClass:[BLCandidateCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.candidateView reloadData];
    [self.candidateView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"candidatebg"]]];
    [_candidateView registerNib:[UINib nibWithNibName:@"BLCandidateCell" bundle:nil] forCellWithReuseIdentifier:kCellID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Candidates

- (void)setCandidates:(NSArray *)candidates
{
    if (!candidates) {
        [_candidates removeAllObjects];
    }else{
        [_candidates setArray:candidates];
    }
    [self.candidateView reloadData];
}

- (void)appendCandidates:(NSArray *)candidates
{
    [self setCandidates:[_candidates arrayByAddingObjectsFromArray:candidates]];
}

- (void)removeCandidates
{
    [self setCandidates:nil];
}

- (void)finishSelection
{
    [_candidatesStack removeAllObjects];
    [_buffer setString:@""];
    _converted = NO;
    _found = NO;
    _selectionIndex = 0;
}

#pragma mark -

- (void)presentSuggestion:(NSString *)text
{
    if (![_buffer isEqualToString:text]) {
        if (_buffer.length > text.length && _candidatesStack[text]) {
            // 後ろへの削除でかつバッファされた予測変換候補があればそれを出す
            [self setCandidates:_candidatesStack[text]];
            _found = YES;
        }else if (text.length == 1 || (text.length > 1 && _found)) {
            [[BLDictionary sharedDictionary] searchForEntriesWithPattern:text found:NULL complete:^(NSString *pattern, NSArray *candidates) {
                BOOL f = (candidates.count > 0);
                _found = f;
                [self setCandidates:candidates];
                if (candidates.count > 0) {
                    [_candidatesStack setObject:candidates forKey:pattern];
                }
            }];
        }else{
            [self removeCandidates];
        }
        [_buffer setString:text];
    }
}

- (void)convertBuffer
{
    NSAssert(_buffer.length != 0, @"");
    if (_converted) {
        // ハイライトを進める
        [self highlightCell:NO atIndex:_selectionIndex];
        [self highlightCell:YES atIndex:_selectionIndex+1];
        _selectionIndex++;
    }else{
        _converted = YES;
        [[BLDictionary sharedDictionary] convertText:_buffer success:^(NSArray *candidates) {
            [self setCandidates:candidates];
            [self highlightCell:YES atIndex:0];
        } failure:^(NSError *e) {
            
        }];
    }
}

- (void)highlightCell:(BOOL)hilight atIndex:(NSInteger)index
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
    [[_candidateView cellForItemAtIndexPath:ip] setHighlighted:hilight];
}

- (IBAction)toggleButtonDidTap:(id)sender {
    CGRect cf = self.view.frame;
    if (_opened) {
        [(UICollectionViewFlowLayout*)_candidateView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _opened = NO;
        // 閉める
        cf.size.height = 55.0f;
    }else{
        [(UICollectionViewFlowLayout*)_candidateView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _opened = YES;
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
    self.view.frame = cf;
//    [self.delegate candidateController:self toggleButtonDidTap:sender open:_opened];
}

#pragma mark - Collection

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _candidates.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BLCandidateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    if (_candidates.count > 0) {
        BLDictEntry *e = [_candidates objectAtIndex:indexPath.row];
        [cell.textLabel setText:e.word];
    }else{
        [cell.textLabel setText:nil];
    }
    return cell;
}

#pragma makr - Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <= _candidates.count - 1) {
        BLDictEntry *c = [_candidates objectAtIndex:indexPath.row];
        // デリゲートに通知
        [_delegate candidateController:self didSelectCandidate:c];
        // 接続文字を出す
        [self setCandidates:[[[BLDictionary sharedDictionary] connectionList] objectForKey:@(c.outConnection)]];
        // スタックを空に
        [self finishSelection];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BLDictEntry *de = [_candidates objectAtIndex:indexPath.row];
    CGSize cons = CGSizeMake(1000, 55.0f);
    CGSize _s = [de.word sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:cons];
    CGSize s = CGSizeZero;
    s.height = 55.0f;
    s.width = MAX(128.0f, _s.width);
    return s;
}
@end
