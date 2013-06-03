//
//  BLKeyboardViewController.m
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/27.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import "BLKeyboardViewController.h"
#import "BLDictionary.h"
#import "BLDictEntry.h"
#import "UIView+FrameChange.h"

@interface BLKeyboardViewController ()
{
    // キーボードを開閉するボタン
    UIButton *_toggleButton;
    //
    BOOL _opened;
}

@end

@implementation BLKeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithClient:(UIResponder<UITextInput,UIKeyInput> *)client
{
    if (self = [super init]) {
        
        BLMainKeyboardViewController *kvc = [[BLMainKeyboardViewController alloc] initWithClient:client];
        BLCandidateViewController *cvc = [[BLCandidateViewController alloc] initWithDelegate:self];
        
        [kvc setCandidateViewController:cvc];
        _client = client;
        _candidateViewController = cvc;
        _mainKeyboardViewController = kvc;
        _toggleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 62, 55)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    BLMainKeyboardViewController *kvc = self.mainKeyboardViewController;
    BLCandidateViewController *cvc = self.candidateViewController;
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    CGRect f = kvc.view.frame;
    f.size.height += CGRectGetHeight(cvc.view.frame);
    [self.view setFrame:f];

    CGRect kvf = self.mainKeyboardViewController.view.frame;
    kvf.origin.y += 55;
    [self.mainKeyboardViewController.view setFrame:kvf];
    [self addChildViewController:kvc];
    [kvc didMoveToParentViewController:self];
    [self addChildViewController:cvc];
    [cvc didMoveToParentViewController:self];
    [self.view addSubview:cvc.view];
    [self.view addSubview:kvc.view];
    
    // 開閉ボタンを設定
    [_toggleButton setImage:[UIImage imageNamed:@"togglebutton"] forState:UIControlStateNormal];
    [_toggleButton addTarget:self action:@selector(toggleCandidateView:) forControlEvents:UIControlEventTouchUpInside];
    [_toggleButton setX:CGRectGetWidth(self.view.frame) - CGRectGetWidth(_toggleButton.frame)];
    [self.view addSubview:_toggleButton];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

#define kLandscapeSize CGSizeMake(1024,352+55)
#define kPortraitSize CGSizeMake(768,264+55)

- (void)toggleCandidateView:(id)sender
{
    CGFloat kh = CGRectGetHeight(self.mainKeyboardViewController.view.frame);
    CGFloat ch = CGRectGetHeight(self.candidateViewController.view.frame);
    if (_opened) {
        // 閉める
        [UIView animateWithDuration:0.3 animations:^{
            [self.candidateViewController.view setHeight:55.0f];
            [self.mainKeyboardViewController.view setHeight:352];
        }];
    }else{
        // 開ける
        [UIView animateWithDuration:0.3 animations:^{
            [self.candidateViewController.view setHeight:kh+ch];
            [self.mainKeyboardViewController.view setHeight:0];
        }];
    }
    _opened = !_opened;
}

- (void)didRotate:(NSNotification*)notification
{
    UIDeviceOrientation orientation = [notification.object orientation];
    if (orientation == UIDeviceOrientationUnknown) {
        orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    if (UIDeviceOrientationIsLandscape(orientation)) {
        // 横
        [self.view setSize:kLandscapeSize];
    }else{
        // 縦
        [self.view setSize:kPortraitSize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)candidateController:(BLCandidateViewController *)controller didSelectCandidate:(BLDictEntry *)candidate
{
    [self.client insertText:candidate.word];
}

- (void)candidateController:(BLCandidateViewController *)controller toggleButtonDidTap:(UIButton *)sender open:(BOOL)open
{
    if (open) {
        CGRect f = self.mainKeyboardViewController.view.frame;
        f.origin.y = CGRectGetHeight(self.view.frame);
        f.size.height = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.mainKeyboardViewController.view.frame = f;
        }];
    }else{
        CGRect f = self.mainKeyboardViewController.view.frame;
        f.size.height = 355;
        f.origin.y += 355;
        [UIView animateWithDuration:0.5 animations:^{
            self.mainKeyboardViewController.view.frame= f;
        }];
    }
}

@end
