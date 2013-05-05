//
//  BPCandidateViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Srakuai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BPCandidateViewController;
@protocol BPCandidateViewControllerDelegate <NSObject>

- (void)candidateController:(BPCandidateViewController*)controller didSelectCandidate:(NSString*)candidate;

@end

@interface BPCandidateViewController : UIViewController
<UICollectionViewDelegate,UICollectionViewDataSource>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<BPCandidateViewControllerDelegate>)delegate;

@property (weak) id<BPCandidateViewControllerDelegate> delegate;

/* 候補を出す */
- (void)generaetCandidateWithText:(NSString*)text;

@end
