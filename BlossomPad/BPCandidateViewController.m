//
//  BPCandidateViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BPCandidateViewController.h"
#import "BPCandidateCell.h"

@interface BPCandidateViewController ()
{
    //
    AFHTTPClient *_httpClient;
    //
    NSMutableArray *_candidates;
    //
    NSMutableDictionary *_candidatesStack;
    // Socket Clien
    SocketIO *_socketIO;
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

@implementation BPCandidateViewController

- (id)initWithDelegate:(id<BPCandidateViewControllerDelegate>)delegate
{
    self = [super initWithNibName:@"BPCandidateViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        _delegate = delegate;
        // HTTPクライアントを作成
        _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://localhost:2342/"]];
        // ソケットクライアントを作成
        _socketIO = [[SocketIO alloc] initWithDelegate:self];
        //　候補バッファを作成
        _candidates = [NSMutableArray array];
        _candidatesStack = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.horizontalCandidateView registerClass:[BPCandidateCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.verticalCandidateView registerClass:[BPCandidateCell class] forCellWithReuseIdentifier:@"Cell"];
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
    
    // ソケットを開く
    [_socketIO connectToHost:@"localhost" onPort:2342];
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
    BPCandidateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
    if (_candidates.count > 0) {
        NSString *s = [_candidates objectAtIndex:indexPath.row];
        [cell.textLabel setText:s];
    }else{
        [cell.textLabel setText:nil];
    }
    return cell;
}

#pragma makr - Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <= _candidates.count - 1) {
        NSString *c = [_candidates objectAtIndex:indexPath.row];
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
        if (hiraBuffer.length > 2) {
            [_socketIO sendEvent:@"suggest" withData:hiraBuffer];
        }else if(hiraBuffer.length == 0){
            [self removeCandidates];
        }
        _hiraBuffer = hiraBuffer;
    }
}

- (void)performConversion
{
    [_socketIO sendEvent:@"kana" withData:_hiraBuffer];
}

#pragma mark - WebSocket

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    TFLog(@"socket error : %@",error);
    [KGStatusBar showErrorWithStatus:NSLocalizedString(@"WebSocket Error", )];
}

- (void)socketIODidConnect:(SocketIO *)socket
{
    TFLog(@"socket io connected");
    [KGStatusBar showSuccessWithStatus:NSLocalizedString(@"WebSocket Connected", )];
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    [KGStatusBar showErrorWithStatus:NSLocalizedString(@"WebSocket Disconnected", )];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if ([packet.name isEqualToString:@"send candidates"]) {
//        TFLog(@"event name : %@, data: %@",packet.name,packet.dataAsJSON);
        [self setCandidates:[packet.args objectAtIndex:0]];
    }
}
@end
