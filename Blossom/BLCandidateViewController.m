//
//  BPCandidateViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLCandidateViewController.h"
#import "BLCandidateCell.h"
#import "BLResource.h"
#import "BLDictionary.h"

@interface BLCandidateViewController ()
{
    //
    AFHTTPClient *_httpClient;
    //
    NSMutableArray *_candidates;
    //
    NSMutableDictionary *_candidatesStack;

}

- (void)setCandidates:(NSArray*)candidates;
- (void)appendCandidates:(NSArray*)candidates;
- (void)removeCandidates;

@property (strong, nonatomic) IBOutlet UIView *openedView;
@property (weak, nonatomic) IBOutlet UICollectionView *verticalCandidateView;

@property (weak, nonatomic) IBOutlet UICollectionView *horizontalCandidateView;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;


@end

@implementation BLCandidateViewController

- (id)initWithDelegate:(id<BLCandidateViewControllerDelegate>)delegate
{
    self = [super initWithNibName:@"BLCandidateViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        _delegate = delegate;
        // HTTPクライアントを作成
        _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://localhost:2342/"]];
        // ソケットクライアントを作成
//        _socketIO = [[SocketIO alloc] initWithDelegate:self];
        //　候補バッファを作成
        _candidates = [NSMutableArray array];
        _candidatesStack = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.horizontalCandidateView registerClass:[BLCandidateCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.verticalCandidateView registerClass:[BLCandidateCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.horizontalCandidateView reloadData];
    [self.horizontalCandidateView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"candidatebg"]]];
    [self.toggleButton addEventHandler:^(id sender) {
        TFLog(@"toggle");
        CGRect f = self.view.frame;
        f.size.height = self.openedView.bounds.size.height;
        [self.view addSubview:self.openedView];
        [UIView animateWithDuration:1 animations:^{
            [self.view setFrame:f];
        } completion:^(BOOL finished) {
            
        }];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Candidates

- (void)setCandidates:(NSArray *)candidates
{
    if (!candidates) {
        [_candidates removeAllObjects];
    }else{
        [_candidates setArray:candidates];
    }
    [self.horizontalCandidateView reloadData];
}

- (void)appendCandidates:(NSArray *)candidates
{
    [self setCandidates:[_candidates arrayByAddingObjectsFromArray:candidates]];
}

- (void)removeCandidates
{
    [self setCandidates:nil];
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
        [self removeCandidates];
    }
}

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
        // なければソケットで予測変換を取得する。バッファが二文字以下の場合はなにもやらない
        [[BLDictionary sharedDictionary] cancelSearch];
        NSMutableArray *candidates = [NSMutableArray array];
        if (hiraBuffer.length > 0) {
            [[BLDictionary sharedDictionary] searchForEntriesWithPattern:hiraBuffer found:^(NSString *pattern, BLDictEntry *entry, BOOL complete, BOOL *stop) {
                [candidates addObject:entry];
                // 10個見つかったら更新
                if (candidates.count > 9) {
                    [self appendCandidates:candidates];
                    [candidates removeAllObjects];
                }
            } notFound:^(NSString *pattern) {
                NSLog(@"not found : %p",pattern);
            }];
        }else if(hiraBuffer.length == 0){
            [self removeCandidates];
        }
        _hiraBuffer = hiraBuffer;
    }
}

@end