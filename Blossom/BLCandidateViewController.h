//
//  BPCandidateViewController.h
//  BlossomPad
//
//  Created by 桜井雄介 on 2013/05/05.
//  Copyright (c) 2013年 Yusuke Sakurai / Keio University Masui Toshiyuki Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLCandidateViewControllerDelegate;

@interface BLCandidateViewController : UIViewController
<UICollectionViewDelegate,UICollectionViewDataSource,SocketIODelegate>

- (id)initWithDelegate:(id<BLCandidateViewControllerDelegate>)delegate;

@property (weak) id<BLCandidateViewControllerDelegate> delegate;
@property (nonatomic) NSString *hiraBuffer;

/* 連文節変換 */
- (void)performConversion;

@end

@protocol BLCandidateViewControllerDelegate <NSObject>

- (void)candidateController:(BLCandidateViewController*)controller didSelectCandidate:(NSString*)candidate;

@end