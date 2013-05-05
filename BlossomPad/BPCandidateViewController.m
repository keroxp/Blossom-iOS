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

@property (strong, nonatomic) IBOutlet UIView *openedView;
@property (weak, nonatomic) IBOutlet UICollectionView *verticalCandidateView;

@property (weak, nonatomic) IBOutlet UICollectionView *horizontalCandidateView;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation BPCandidateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.horizontalCandidateView registerClass:[BPCandidateCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.verticalCandidateView registerClass:[BPCandidateCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.horizontalCandidateView reloadData];
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
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"Cell";
    BPCandidateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
    cell.textLabel.text = @"候補";
    return cell;
}

@end
