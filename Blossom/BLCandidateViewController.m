//
//  BPCandidateViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLCandidateViewController.h"
#import "BLMainKeyboardViewController.h"
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
}

- (void)setCandidates:(NSArray*)candidates;
- (void)appendCandidates:(NSArray*)candidates;
- (void)removeCandidates;
- (BLMainKeyboardViewController*)keyboardViewController;

- (IBAction)toggleButtonDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *candidateView;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.candidateView registerClass:[BLCandidateCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.candidateView reloadData];
    [self.candidateView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"candidatebg"]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;

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

- (IBAction)toggleButtonDidTap:(id)sender {
    if (_opened) {
        _opened = NO;
    }else{
        _opened = YES;
    }
    [self.delegate candidateController:self toggleButtonDidTap:sender open:_opened];
}

- (void)deviceDidRotate:(NSNotification*)notification
{
//      [self.view updateConstraints];
}
- (BLMainKeyboardViewController *)keyboardViewController
{
    return (BLMainKeyboardViewController*)self.delegate;
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
        [_delegate candidateController:self didSelectCandidate:c];
        [self setCandidates:[[[BLDictionary sharedDictionary] connectionList] objectForKey:@(c.outConnection)]];
//        [self removeCandidates];
    }
}

#pragma makr - Accessors

- (void)setHiraBuffer:(NSString *)hiraBuffer
{
    if (![_hiraBuffer isEqualToString:hiraBuffer]) {
        if (_hiraBuffer.length > hiraBuffer.length) {
            // 後ろへの削除でかつバッファされた予測変換候補があればそれを出す
            NSArray *cands = [_candidatesStack objectForKey:hiraBuffer];
            if (cands) {
                [self setCandidates:cands];
                return;
            }
        }
        if (hiraBuffer.length > 0) {
            [[BLDictionary sharedDictionary] searchForEntriesWithPattern:hiraBuffer found:NULL complete:^(NSString *pattern, NSArray *candidates) {
                [self setCandidates:candidates];
            }];
        }else if(hiraBuffer.length == 0){
            [self removeCandidates];
        }
        _hiraBuffer = hiraBuffer;
    }
}

@end
