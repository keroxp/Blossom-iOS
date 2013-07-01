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

@interface BLCandidateViewController ()
{
    // 現在表示している候補
    NSMutableArray *_candidates;
    // バッファの追加・削除毎に結果を保持しておくKVS
    NSMutableDictionary *_candidatesStack;
    //
    NSMutableString *_buffer;
    BOOL _found;
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
}

#pragma mark -

- (void)presentSuggestion:(NSString *)text
{
    if (![_buffer isEqualToString:text]) {
        if (_buffer.length > text.length) {
            // 後ろへの削除でかつバッファされた予測変換候補があればそれを出す
            NSArray *cands = [_candidatesStack objectForKey:text];
            if (cands) {
                _found = YES;
                [self setCandidates:cands];
            }
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
    [[BLDictionary sharedDictionary] convertText:_buffer success:^(id candidates) {
        if ([candidates isKindOfClass:[NSArray class]]) {
            NSArray *r = (NSArray*)candidates;
            for (id obj in r) {
                TFLog(@"%@",obj);
            }
        }
    } failure:^(NSError *e) {
        
    }];
}

- (IBAction)toggleButtonDidTap:(id)sender {
    if (_opened) {
        _opened = NO;
    }else{
        _opened = YES;
    }
    [self.delegate candidateController:self toggleButtonDidTap:sender open:_opened];
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
    static NSString *CellID = @"Cell";
    BLCandidateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
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
        [_candidatesStack removeAllObjects];
        // バッファを空に
        [_buffer setString:@""];
    }
}


@end
