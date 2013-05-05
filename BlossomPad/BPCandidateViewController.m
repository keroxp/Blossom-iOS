//
//  BPCandidateViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BPCandidateViewController.h"
#import "BPCandidateCell.h"

@interface BPCandidateViewController ()
{
    //
    AFHTTPClient *_httpClient;
    NSMutableArray *_candidates;
}


@property (strong, nonatomic) IBOutlet UIView *openedView;
@property (weak, nonatomic) IBOutlet UICollectionView *verticalCandidateView;

@property (weak, nonatomic) IBOutlet UICollectionView *horizontalCandidateView;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;


@end

@implementation BPCandidateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<BPCandidateViewControllerDelegate>)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://192.168.11.23:2342/"]];
    _candidates = [NSMutableArray array];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [_candidates removeAllObjects];
        [collectionView reloadData];
    }
}

- (void)generaetCandidateWithText:(NSString *)text
{
    [_httpClient getPath:@"" parameters:@{@"mode" : @"0", @"hira" : text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resstr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSArray *cands = [resstr objectFromJSONStringWithParseOptions:0 error:&e];
        if (e) {
            TFLog(@"%@",e);
            abort();
        }
        [_candidates setArray:cands];
        [self.horizontalCandidateView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        TFLog(@"%@",error);
    }];
}

@end
